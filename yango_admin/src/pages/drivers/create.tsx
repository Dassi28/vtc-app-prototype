import { Create, useForm } from "@refinedev/antd";
import { Form, Input } from "antd";

export const DriverCreate = () => {
    const { formProps, saveButtonProps } = useForm();
    // Logic to create user in Auth and DB simultaneously is complex for Refine standard create.
    // Usually admin uses a special Supabase Edge Function to create users.
    // For this prototype, we will just show the form structure.

    return (
        <Create saveButtonProps={saveButtonProps}>
            <Form {...formProps} layout="vertical">
                <Form.Item label="Email" name="email" rules={[{ required: true }]}>
                    <Input />
                </Form.Item>
                <Form.Item label="Nom Complet" name="full_name" rules={[{ required: true }]}>
                    <Input />
                </Form.Item>
                <Form.Item label="Téléphone" name="phone" rules={[{ required: true }]}>
                    <Input />
                </Form.Item>

                {/* Driver specific */}
                <Form.Item label="Marque Véhicule" name="vehicle_brand" rules={[{ required: true }]}>
                    <Input />
                </Form.Item>
                <Form.Item label="Modèle" name="vehicle_model" rules={[{ required: true }]}>
                    <Input />
                </Form.Item>
                <Form.Item label="Plaque" name="license_plate" rules={[{ required: true }]}>
                    <Input />
                </Form.Item>
            </Form>
        </Create>
    );
};

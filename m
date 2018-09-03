Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 177076B6841
	for <linux-mm@kvack.org>; Mon,  3 Sep 2018 10:10:55 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id 189-v6so117748ybz.11
        for <linux-mm@kvack.org>; Mon, 03 Sep 2018 07:10:55 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id t62-v6si4705703ybf.623.2018.09.03.07.10.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Sep 2018 07:10:54 -0700 (PDT)
From: Nikita Leshenko <nikita.leshchenko@oracle.com>
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [RFC][PATCH 1/5] [PATCH 1/5] kvm: register in task_struct
Message-Id: <D3FBF73C-3C33-4F94-8BBB-CE6C70B81A70@oracle.com>
Date: Mon, 3 Sep 2018 16:10:22 +0200
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, fengguang.wu@intel.com, dongx.peng@intel.com, jingqi.liu@intel.com, eddie.dong@intel.com, dave.hansen@intel.com, ying.huang@intel.com, bgregg@netflix.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org

On September 2, 2018 5:21:15 AM, fengguang.wu@intel.com wrote:
> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
> index 8b47507faab5..0c483720de8d 100644
> --- a/virt/kvm/kvm_main.c
> +++ b/virt/kvm/kvm_main.c
> @@ -3892,6 +3892,7 @@ static void kvm_uevent_notify_change(unsigned =
int type, struct kvm *kvm)
>  	if (type =3D=3D KVM_EVENT_CREATE_VM) {
>  		add_uevent_var(env, "EVENT=3Dcreate");
>  		kvm->userspace_pid =3D task_pid_nr(current);
> +		current->kvm =3D kvm;

Is it OK to store `kvm` on the task_struct? What if the thread that
originally created the VM exits? =46rom the documentation it seems
like a VM is associated with an address space and not a specific
thread, so maybe it should be stored on mm_struct?

=46rom Documentation/virtual/kvm/api.txt:
   Only run VM ioctls from the same process (address space) that was =
used
   to create the VM.

-Nikita
>  	} else if (type =3D=3D KVM_EVENT_DESTROY_VM) {
>  		add_uevent_var(env, "EVENT=3Ddestroy");
>  	}
> --=20
> 2.15.0
>=20
>=20
>=20

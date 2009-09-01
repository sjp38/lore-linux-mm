Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0D5C36B004D
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 01:05:45 -0400 (EDT)
From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Date: Tue, 1 Sep 2009 13:04:58 +0800
Subject: RE: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
Message-ID: <C85CEDA13AB1CF4D9D597824A86D2B9006AEB9477C@PDSMSX501.ccr.corp.intel.com>
References: <E88DD564E9DC5446A76B2B47C3BCCA150219600F9B@pdsmsx503.ccr.corp.intel.com>
 <C85CEDA13AB1CF4D9D597824A86D2B9006AEB944B8@PDSMSX501.ccr.corp.intel.com>
 <4A9C0DC2.6080704@redhat.com>
In-Reply-To: <4A9C0DC2.6080704@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: "mst@redhat.com" <mst@redhat.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mingo@elte.hu" <mingo@elte.hu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "gregory.haskins@gmail.com" <gregory.haskins@gmail.com>
List-ID: <linux-mm.kvack.org>

> One way to share the effort is to make vmdq queues available as normal=20
kernel interfaces.  It would take quite a bit of work, but the end=20
result is that no other components need to be change, and it makes vmdq=20
useful outside kvm.  It also greatly reduces the amount of integration=20
work needed throughout the stack (kvm/qemu/libvirt).

Yes. The common queue pair interface which we want to present will also app=
ly to normal hardware, and try to leave other components unknown.

Thanks
Xiaohui

-----Original Message-----
From: Avi Kivity [mailto:avi@redhat.com]=20
Sent: Tuesday, September 01, 2009 1:52 AM
To: Xin, Xiaohui
Cc: mst@redhat.com; netdev@vger.kernel.org; virtualization@lists.linux-foun=
dation.org; kvm@vger.kernel.org; linux-kernel@vger.kernel.org; mingo@elte.h=
u; linux-mm@kvack.org; akpm@linux-foundation.org; hpa@zytor.com; gregory.ha=
skins@gmail.com
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server

On 08/31/2009 02:42 PM, Xin, Xiaohui wrote:
> Hi, Michael
> That's a great job. We are now working on support VMDq on KVM, and since =
the VMDq hardware presents L2 sorting based on MAC addresses and VLAN tags,=
 our target is to implement a zero copy solution using VMDq. We stared from=
 the virtio-net architecture. What we want to proposal is to use AIO combin=
ed with direct I/O:
> 1) Modify virtio-net Backend service in Qemu to submit aio requests compo=
sed from virtqueue.
> 2) Modify TUN/TAP device to support aio operations and the user space buf=
fer directly mapping into the host kernel.
> 3) Let a TUN/TAP device binds to single rx/tx queue from the NIC.
> 4) Modify the net_dev and skb structure to permit allocated skb to use us=
er space directly mapped payload buffer address rather then kernel allocate=
d.
>
> As zero copy is also your goal, we are interested in what's in your mind,=
 and would like to collaborate with you if possible.
>   =20

One way to share the effort is to make vmdq queues available as normal=20
kernel interfaces.  It would take quite a bit of work, but the end=20
result is that no other components need to be change, and it makes vmdq=20
useful outside kvm.  It also greatly reduces the amount of integration=20
work needed throughout the stack (kvm/qemu/libvirt).

--=20
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

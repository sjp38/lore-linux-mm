Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1BE8D6B004F
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 11:37:21 -0400 (EDT)
From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Date: Tue, 1 Sep 2009 23:37:01 +0800
Subject: RE: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
Message-ID: <C85CEDA13AB1CF4D9D597824A86D2B9006AEC02ED8@PDSMSX501.ccr.corp.intel.com>
References: <E88DD564E9DC5446A76B2B47C3BCCA150219600F9B@pdsmsx503.ccr.corp.intel.com>
 <C85CEDA13AB1CF4D9D597824A86D2B9006AEB944B8@PDSMSX501.ccr.corp.intel.com>
 <4A9C0DC2.6080704@redhat.com> <4A9C4723.5080309@codemonkey.ws>
In-Reply-To: <4A9C4723.5080309@codemonkey.ws>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Anthony Liguori <anthony@codemonkey.ws>, Avi Kivity <avi@redhat.com>
Cc: "mst@redhat.com" <mst@redhat.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mingo@elte.hu" <mingo@elte.hu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "gregory.haskins@gmail.com" <gregory.haskins@gmail.com>
List-ID: <linux-mm.kvack.org>


>It may be possible to make vmdq appear like an sr-iov capable device=20
>from userspace.  sr-iov provides the userspace interfaces to allocate=20
>interfaces and assign mac addresses.  To make it useful, you would have=20
>to handle tx multiplexing in the driver but that would be much easier to=20
>consume for kvm

What we have thought is to support multiple net_dev structures=20
according to multiple queue pairs of one vmdq adapter and presents
multiple mac address in user space and each one mac can be used=20
by a guest.=20
What does the tx multiplexing in the driver exactly mean?

Thanks
Xiaohui

-----Original Message-----
From: Anthony Liguori [mailto:anthony@codemonkey.ws]=20
Sent: Tuesday, September 01, 2009 5:57 AM
To: Avi Kivity
Cc: Xin, Xiaohui; mst@redhat.com; netdev@vger.kernel.org; virtualization@li=
sts.linux-foundation.org; kvm@vger.kernel.org; linux-kernel@vger.kernel.org=
; mingo@elte.hu; linux-mm@kvack.org; akpm@linux-foundation.org; hpa@zytor.c=
om; gregory.haskins@gmail.com
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server

Avi Kivity wrote:
> On 08/31/2009 02:42 PM, Xin, Xiaohui wrote:
>> Hi, Michael
>> That's a great job. We are now working on support VMDq on KVM, and=20
>> since the VMDq hardware presents L2 sorting based on MAC addresses=20
>> and VLAN tags, our target is to implement a zero copy solution using=20
>> VMDq. We stared from the virtio-net architecture. What we want to=20
>> proposal is to use AIO combined with direct I/O:
>> 1) Modify virtio-net Backend service in Qemu to submit aio requests=20
>> composed from virtqueue.
>> 2) Modify TUN/TAP device to support aio operations and the user space=20
>> buffer directly mapping into the host kernel.
>> 3) Let a TUN/TAP device binds to single rx/tx queue from the NIC.
>> 4) Modify the net_dev and skb structure to permit allocated skb to=20
>> use user space directly mapped payload buffer address rather then=20
>> kernel allocated.
>>
>> As zero copy is also your goal, we are interested in what's in your=20
>> mind, and would like to collaborate with you if possible.
>>   =20
>
> One way to share the effort is to make vmdq queues available as normal=20
> kernel interfaces.

It may be possible to make vmdq appear like an sr-iov capable device=20
from userspace.  sr-iov provides the userspace interfaces to allocate=20
interfaces and assign mac addresses.  To make it useful, you would have=20
to handle tx multiplexing in the driver but that would be much easier to=20
consume for kvm.

Regards,

Anthony Liguori

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

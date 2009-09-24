Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id BBA416B004D
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 04:03:23 -0400 (EDT)
Message-ID: <4ABB27B9.4050904@redhat.com>
Date: Thu, 24 Sep 2009 11:03:05 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <4AAFACB5.9050808@redhat.com> <4AAFF437.7060100@gmail.com> <4AB0A070.1050400@redhat.com> <4AB0CFA5.6040104@gmail.com> <4AB0E2A2.3080409@redhat.com> <4AB0F1EF.5050102@gmail.com> <4AB10B67.2050108@redhat.com> <4AB13B09.5040308@gmail.com> <4AB151D7.10402@redhat.com> <4AB1A8FD.2010805@gmail.com> <20090921214312.GJ7182@ovro.caltech.edu> <4AB89C48.4020903@redhat.com> <4ABA3005.60905@gmail.com> <4ABA32AF.50602@redhat.com> <4ABA3A73.5090508@gmail.com> <4ABA61D1.80703@gmail.com> <4ABA78DC.7070604@redhat.com>
In-Reply-To: <4ABA78DC.7070604@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Cc: "Ira W. Snyder" <iws@ovro.caltech.edu>, "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On 09/23/2009 10:37 PM, Avi Kivity wrote:
>
> Example: feature negotiation.  If it happens in userspace, it's easy 
> to limit what features we expose to the guest.  If it happens in the 
> kernel, we need to add an interface to let the kernel know which 
> features it should expose to the guest.  We also need to add an 
> interface to let userspace know which features were negotiated, if we 
> want to implement live migration.  Something fairly trivial bloats 
> rapidly.

btw, we have this issue with kvm reporting cpuid bits to the guest.  
Instead of letting kvm talk directly to the hardware and the guest, kvm 
gets the cpuid bits from the hardware, strips away features it doesn't 
support, exposes that to userspace, and expects userspace to program the 
cpuid bits it wants to expose to the guest (which may be different than 
what kvm exposed to userspace, and different from guest to guest).

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

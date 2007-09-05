Message-ID: <46DF0EC2.7090408@qumranet.com>
Date: Wed, 05 Sep 2007 23:17:06 +0300
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: [kvm-devel] [PATCH][RFC] pte notifiers -- support for external
 page tables
References: <11890207643068-git-send-email-avi@qumranet.com> <1189022183.10802.184.camel@localhost.localdomain>
In-Reply-To: <1189022183.10802.184.camel@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org
List-ID: <linux-mm.kvack.org>

Rusty Russell wrote:
> On Wed, 2007-09-05 at 22:32 +0300, Avi Kivity wrote:
>   
>> [resend due to bad alias expansion resulting in some recipients
>>  being bogus]
>>
>> Some hardware and software systems maintain page tables outside the normal
>> Linux page tables, which reference userspace memory.  This includes
>> Infiniband, other RDMA-capable devices, and kvm (with a pending patch).
>>     
>
> And lguest.  I can't tell until I've actually implemented it, but I
> think it will seriously reduce the need for page pinning which is why
> only root can currently launch guests.
>
>   

Ah yes, lguest.

> My concern is locking: this is called with the page lock held, and I
> guess we have to bump the guest out if it's currently running.
>   

This will complicate kvm's locking too.  We usually take kvm->lock to do 
mmu ops, but that is now a mutex.


-- 
Any sufficiently difficult bug is indistinguishable from a feature.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

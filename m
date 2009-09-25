Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C41E76B005D
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 03:44:00 -0400 (EDT)
Message-ID: <4ABC74B3.9070102@redhat.com>
Date: Fri, 25 Sep 2009 10:43:47 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
References: <4AB1A8FD.2010805@gmail.com> <20090921214312.GJ7182@ovro.caltech.edu> <4AB89C48.4020903@redhat.com> <4ABA3005.60905@gmail.com> <4ABA32AF.50602@redhat.com> <4ABA3A73.5090508@gmail.com> <4ABA61D1.80703@gmail.com> <4ABA78DC.7070604@redhat.com> <4ABA8FDC.5010008@gmail.com> <4ABB1D44.5000007@redhat.com> <20090924192754.GA14341@ovro.caltech.edu>
In-Reply-To: <20090924192754.GA14341@ovro.caltech.edu>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Ira W. Snyder" <iws@ovro.caltech.edu>
Cc: Gregory Haskins <gregory.haskins@gmail.com>, "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On 09/24/2009 10:27 PM, Ira W. Snyder wrote:
>>> Ira can make ira-bus, and ira-eventfd, etc, etc.
>>>
>>> Each iteration will invariably introduce duplicated parts of the stack.
>>>
>>>        
>> Invariably?  Use libraries (virtio-shmem.ko, libvhost.so).
>>
>>      
> Referencing libraries that don't yet exist doesn't seem like a good
> argument against vbus from my point of view. I'm not speficially
> advocating for vbus; I'm just letting you know how it looks to another
> developer in the trenches.
>    

My argument is that we shouldn't write a new framework instead of fixing 
or extending an existing one.

> If you'd like to see the amount of duplication present, look at the code
> I'm currently working on.

Yes, virtio-phys-guest looks pretty much duplicated.  Looks like it 
should be pretty easy to deduplicate.

>   It mostly works at this point, though I
> haven't finished my userspace, nor figured out how to actually transfer
> data.
>
> The current question I have (just to let you know where I am in
> development) is:
>
> I have the physical address of the remote data, but how do I get it into
> a userspace buffer, so I can pass it to tun?
>    

vhost does guest physical address to host userspace address (it your 
scenario, remote physical to local virtual) using a table of memory 
slots; there's an ioctl that allows userspace to initialize that table.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

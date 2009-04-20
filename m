Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E48AF5F0001
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 08:52:27 -0400 (EDT)
Message-ID: <49EC7005.7000909@redhat.com>
Date: Mon, 20 Apr 2009 15:52:21 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/5] add ksm kernel shared memory driver.
References: <1240191366-10029-1-git-send-email-ieidus@redhat.com>	<1240191366-10029-2-git-send-email-ieidus@redhat.com>	<1240191366-10029-3-git-send-email-ieidus@redhat.com>	<1240191366-10029-4-git-send-email-ieidus@redhat.com>	<1240191366-10029-5-git-send-email-ieidus@redhat.com>	<1240191366-10029-6-git-send-email-ieidus@redhat.com> <20090420110223.76ba4593@lxorguk.ukuu.org.uk> <49EC584B.3060809@redhat.com>
In-Reply-To: <49EC584B.3060809@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, mtosatti@redhat.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Avi Kivity wrote:
> Alan Cox wrote:
>> The minor number you are using already belongs to another project.
>>
>> 10,234 is free but it would be good to know what device naming is
>> proposed. I imagine other folks would like to know why you aren't using
>> sysfs or similar or extending /dev/kvm ?
>>   
>
> ksm was deliberately made independent of kvm.  While there may or may 
> not be uses of ksm without kvm (you could run ordinary qemu, but no 
> one would do this in a production deployment), keeping them separate 
> helps avoid unnecessary interdependencies.  For example all tlb 
> flushes are mediated through mmu notifiers instead of ksm hooking 
> directly into kvm.
>
Yes, beside, I do use sysfs for controlling the ksm behavior,
Ioctls are provided as easier way for application to register its memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

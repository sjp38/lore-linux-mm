Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6BC076B003D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 08:37:53 -0400 (EDT)
Message-ID: <49D20DAF.6000805@redhat.com>
Date: Tue, 31 Mar 2009 15:33:51 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] ksm - dynamic page sharing driver for linux
References: <1238457560-7613-1-git-send-email-ieidus@redhat.com> <49D174FC.80900@codemonkey.ws>
In-Reply-To: <49D174FC.80900@codemonkey.ws>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Anthony Liguori <anthony@codemonkey.ws>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, yaniv@redhat.com, dmonakhov@openvz.org
List-ID: <linux-mm.kvack.org>

Anthony Liguori wrote:
> Izik Eidus wrote:
>> I am sending another seires of patchs for kvm kernel and kvm-userspace
>> that would allow users of kvm to test ksm with it.
>> The kvm patchs would apply to Avi git tree.
>>   
> Any reason to not take these through upstream QEMU instead of 
> kvm-userspace?  In principle, I don't see anything that would prevent 
> normal QEMU from almost making use of this functionality.  That would 
> make it one less thing to eventually have to merge...

The changes for the kvm-userspace were just provided for testing it...
After we will have ksm inside the kernel we will send another patch to 
qemu-devel that will add support for it.

>
> Regards,
>
> Anthony Liguori

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

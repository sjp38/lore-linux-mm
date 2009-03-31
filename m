Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id CB55A6B004D
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 22:12:16 -0400 (EDT)
Received: by qw-out-1920.google.com with SMTP id 9so1813497qwj.44
        for <linux-mm@kvack.org>; Mon, 30 Mar 2009 19:12:25 -0700 (PDT)
Message-ID: <49D17C04.9070307@codemonkey.ws>
Date: Mon, 30 Mar 2009 21:12:20 -0500
From: Anthony Liguori <anthony@codemonkey.ws>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] add ksm kernel shared memory driver.
References: <1238457560-7613-1-git-send-email-ieidus@redhat.com> <1238457560-7613-2-git-send-email-ieidus@redhat.com> <1238457560-7613-3-git-send-email-ieidus@redhat.com> <1238457560-7613-4-git-send-email-ieidus@redhat.com> <1238457560-7613-5-git-send-email-ieidus@redhat.com>
In-Reply-To: <1238457560-7613-5-git-send-email-ieidus@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, yaniv@redhat.com, dmonakhov@openvz.org
List-ID: <linux-mm.kvack.org>

Izik Eidus wrote:
> Ksm is driver that allow merging identical pages between one or more
> applications in way unvisible to the application that use it.
> Pages that are merged are marked as readonly and are COWed when any
> application try to change them.
>
> Ksm is used for cases where using fork() is not suitable,
> one of this cases is where the pages of the application keep changing
> dynamicly and the application cannot know in advance what pages are
> going to be identical.
>
> Ksm works by walking over the memory pages of the applications it
> scan in order to find identical pages.
> It uses a two sorted data strctures called stable and unstable trees
> to find in effective way the identical pages.
>
> When ksm finds two identical pages, it marks them as readonly and merges
> them into single one page,
> after the pages are marked as readonly and merged into one page, linux
> will treat this pages as normal copy_on_write pages and will fork them
> when write access will happen to them.
>
> Ksm scan just memory areas that were registred to be scanned by it.
>
> Ksm api:
>
> KSM_GET_API_VERSION:
> Give the userspace the api version of the module.
>
> KSM_CREATE_SHARED_MEMORY_AREA:
> Create shared memory reagion fd, that latter allow the user to register
> the memory region to scan by using:
> KSM_REGISTER_MEMORY_REGION and KSM_REMOVE_MEMORY_REGION
>
> KSM_START_STOP_KTHREAD:
> Return information about the kernel thread, the inforamtion is returned
> using the ksm_kthread_info structure:
> ksm_kthread_info:
> __u32 sleep:
>         number of microsecoends to sleep between each iteration of
> scanning.
>
> __u32 pages_to_scan:
>         number of pages to scan for each iteration of scanning.
>
> __u32 max_pages_to_merge:
>         maximum number of pages to merge in each iteration of scanning
>         (so even if there are still more pages to scan, we stop this
> iteration)
>
> __u32 flags:
>        flags to control ksmd (right now just ksm_control_flags_run
> 			      available)
>   

Wouldn't this make more sense as a sysfs interface?  That is, the 
KSM_START_STOP_KTHREAD part, not necessarily the rest of the API.

Regards,

Anthony Liguori

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

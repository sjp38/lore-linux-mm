Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C546D6B014C
	for <linux-mm@kvack.org>; Wed, 13 May 2009 20:20:13 -0400 (EDT)
Message-ID: <4A0B6289.2000502@redhat.com>
Date: Thu, 14 May 2009 03:15:05 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/5] add ksm kernel shared memory driver.
References: <1240191366-10029-1-git-send-email-ieidus@redhat.com>	<1240191366-10029-2-git-send-email-ieidus@redhat.com>	<1240191366-10029-3-git-send-email-ieidus@redhat.com>	<1240191366-10029-4-git-send-email-ieidus@redhat.com>	<1240191366-10029-5-git-send-email-ieidus@redhat.com>	<1240191366-10029-6-git-send-email-ieidus@redhat.com> <20090513161739.d801ab67.akpm@linux-foundation.org>
In-Reply-To: <20090513161739.d801ab67.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, mtosatti@redhat.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Mon, 20 Apr 2009 04:36:06 +0300
> Izik Eidus <ieidus@redhat.com> wrote:
>
>   
>> Ksm is driver that allow merging identical pages between one or more
>> applications in way unvisible to the application that use it.
>> Pages that are merged are marked as readonly and are COWed when any
>> application try to change them.
>>
>> Ksm is used for cases where using fork() is not suitable,
>> one of this cases is where the pages of the application keep changing
>> dynamicly and the application cannot know in advance what pages are
>> going to be identical.
>>
>> Ksm works by walking over the memory pages of the applications it
>> scan in order to find identical pages.
>> It uses a two sorted data strctures called stable and unstable trees
>> to find in effective way the identical pages.
>>
>> When ksm finds two identical pages, it marks them as readonly and merges
>> them into single one page,
>> after the pages are marked as readonly and merged into one page, linux
>> will treat this pages as normal copy_on_write pages and will fork them
>> when write access will happen to them.
>>
>> Ksm scan just memory areas that were registred to be scanned by it.
>>
>> ...
>> +	copy_user_highpage(kpage, page1, addr1, vma);
>> ...
>>     
>
> Breaks ppc64 allmodcofnig because that architecture doesn't export its
> copy_user_page() to modules.
>
> Architectures are inconsistent about this.  x86 _does_ export it,
> because it bounces it to the exported copy_page().
>
> So can I ask that you sit down and work out upon which architectures it
> really makes sense to offer KSM?  Disallow the others in Kconfig and
> arrange for copy_user_highpage() to be available on the allowed architectures?
>   

Hi

There is some way (script) that i can run that will allow compile this 
code for every possible arch?

(I dont mind to allow it just for archs that support virtualization - 
x86, ia64, powerpc, s390, but is it the right thing to do ?)
> Thanks.
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

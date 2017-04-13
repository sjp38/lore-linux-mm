Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 02EFF6B0390
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 07:06:19 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id m1so31730447pgd.13
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 04:06:18 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id c17si23659925pgh.23.2017.04.13.04.06.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Apr 2017 04:06:18 -0700 (PDT)
Message-ID: <58EF5C0D.60603@intel.com>
Date: Thu, 13 Apr 2017 19:07:57 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH kernel v8 3/4] mm: add inerface to offer info about unused
 pages
References: <1489648127-37282-1-git-send-email-wei.w.wang@intel.com>	<1489648127-37282-4-git-send-email-wei.w.wang@intel.com> <20170316142842.69770813b98df70277431b1e@linux-foundation.org>
In-Reply-To: <20170316142842.69770813b98df70277431b1e@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com

On 03/17/2017 05:28 AM, Andrew Morton wrote:
> On Thu, 16 Mar 2017 15:08:46 +0800 Wei Wang <wei.w.wang@intel.com> wrote:
>
>> From: Liang Li <liang.z.li@intel.com>
>>
>> This patch adds a function to provides a snapshot of the present system
>> unused pages. An important usage of this function is to provide the
>> unsused pages to the Live migration thread, which skips the transfer of
>> thoses unused pages. Newly used pages can be re-tracked by the dirty
>> page logging mechanisms.
> I don't think this will be useful for anything other than
> virtio-balloon.  I guess it would be better to keep this code in the
> virtio-balloon driver if possible, even though that's rather a layering
> violation :( What would have to be done to make that possible?  Perhaps
> we can put some *small* helpers into page_alloc.c to prevent things
> from becoming too ugly.
>
>
Thanks for the suggestion. Small helpers do look more elegant. The nice 
thing is that I also didn't see any performance loss.
To make that possible, we need to enable for_each_polulated_zone() to be 
callable by a kernel module. Please have a check the v9 patches that I 
just posted out.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

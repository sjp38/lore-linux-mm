Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2BB156B0389
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 00:06:13 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c87so56419573pfl.6
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 21:06:13 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id z15si7294673pll.224.2017.03.16.21.06.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 21:06:12 -0700 (PDT)
Date: Fri, 17 Mar 2017 12:06:08 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [kbuild-all] [mmotm:master 119/211] mm/migrate.c:2184:5: note:
 in expansion of macro 'MIGRATE_PFN_DEVICE'
Message-ID: <20170317040608.islf67cjbe25rjnx@wfg-t540p.sh.intel.com>
References: <201703170923.JOG5lvVO%fengguang.wu@intel.com>
 <20170316204135.da11fb9a50d22c264404a30e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170316204135.da11fb9a50d22c264404a30e@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>

Hi Andrew,

On Thu, Mar 16, 2017 at 08:41:35PM -0700, Andrew Morton wrote:
>On Fri, 17 Mar 2017 09:46:30 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
>
>> tree:   git://git.cmpxchg.org/linux-mmotm.git master
>> head:   8276ddb3c638602509386f1a05f75326dbf5ce09
>> commit: a6d9a210db7db40e98f7502608c6f1413c44b9b9 [119/211] mm/hmm/migrate: support un-addressable ZONE_DEVICE page in migration
>
>heh, I think the HMM patchset just scored the world record number of
>build errors.  Thanks for doing this.
>
>But why didn't we find out earlier than v18?  Don't you scoop patchsets
>off the mailing list *before* someone merges them into an upstream
>tree?

Yes we test LKML patches, however not all patches can be successfully
applied, so cannot be tested at all.

There is a way to significantly increase the chance of finding the
right git-apply base, however this idea needs buy-in by the GIT community:

        https://lkml.org/lkml/2017/3/9/956

Currently we rely on heuristics and try-outs to select a git base.
For this patchset, log shows it cannot be applied to all of these
common bases

- linus/master
- recent RC kernels
- mmotm/master
- linux-next/master


[2017-01-13 13:45:44] Applying to linus/master..linux-review/J-r-me-Glisse/mm-memory-hotplug-convert-device-bool-to-int-to-allow-for-more-flags-v2/20170113-134544
[2017-01-13 13:45:45] Applying to linux/master..linux-review/J-r-me-Glisse/mm-memory-hotplug-convert-device-bool-to-int-to-allow-for-more-flags-v2/20170113-134545
[2017-01-13 13:45:52] Applying to mmotm/master..linux-review/J-r-me-Glisse/mm-memory-hotplug-convert-device-bool-to-int-to-allow-for-more-flags-v2/20170113-134552
[2017-01-13 13:46:03] Applying to v4.9-rc8..linux-review/J-r-me-Glisse/mm-memory-hotplug-convert-device-bool-to-int-to-allow-for-more-flags-v2/20170113-134603
[2017-01-13 13:46:10] Applying to v4.9-rc7..linux-review/J-r-me-Glisse/mm-memory-hotplug-convert-device-bool-to-int-to-allow-for-more-flags-v2/20170113-134610
[2017-01-13 13:46:14] Applying to v4.9-rc6..linux-review/J-r-me-Glisse/mm-memory-hotplug-convert-device-bool-to-int-to-allow-for-more-flags-v2/20170113-134614
[2017-01-13 13:46:17] Applying to next-20170111..linux-review/J-r-me-Glisse/mm-memory-hotplug-convert-device-bool-to-int-to-allow-for-more-flags-v2/20170113-134617
[2017-01-13 13:46:25] >>> apply-failed: "JA(C)rA'me Glisse" <jglisse@redhat.com> [HMM v16 01/15] mm/memory/hotplug: convert device bool to int to allow for more flags v2
[2017-01-13 13:46:25] >>> apply-failed: "JA(C)rA'me Glisse" <jglisse@redhat.com> [HMM v16 02/15] mm/ZONE_DEVICE/devmem_pages_remove: allow early removal of device memory v2
[2017-01-13 13:46:25] >>> apply-failed: "JA(C)rA'me Glisse" <jglisse@redhat.com> [HMM v16 03/15] mm/ZONE_DEVICE/free-page: callback when page is freed
[2017-01-13 13:46:25] >>> apply-failed: "JA(C)rA'me Glisse" <jglisse@redhat.com> [HMM v16 04/15] mm/ZONE_DEVICE/unaddressable: add support for un-addressable device memory v2
[2017-01-13 13:46:25] >>> apply-failed: "JA(C)rA'me Glisse" <jglisse@redhat.com> [HMM v16 05/15] mm/ZONE_DEVICE/x86: add support for un-addressable device memory
[2017-01-13 13:46:25] >>> apply-failed: "JA(C)rA'me Glisse" <jglisse@redhat.com> [HMM v16 06/15] mm/hmm: heterogeneous memory management (HMM for short)
[2017-01-13 13:46:25] >>> apply-failed: "JA(C)rA'me Glisse" <jglisse@redhat.com> [HMM v16 07/15] mm/hmm/mirror: mirror process address space on device with HMM helpers
[2017-01-13 13:46:25] >>> apply-failed: "JA(C)rA'me Glisse" <jglisse@redhat.com> [HMM v16 08/15] mm/hmm/mirror: helper to snapshot CPU page table
[2017-01-13 13:46:25] >>> apply-failed: "JA(C)rA'me Glisse" <jglisse@redhat.com> [HMM v16 09/15] mm/hmm/mirror: device page fault handler
[2017-01-13 13:46:25] >>> apply-failed: "JA(C)rA'me Glisse" <jglisse@redhat.com> [HMM v16 10/15] mm/hmm/migrate: support un-addressable ZONE_DEVICE page in migration
...

Best Regards,
Fengguang Wu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

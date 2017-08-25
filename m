Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7E9356810C8
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 16:01:50 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b189so1032036wmd.3
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 13:01:50 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z133si1761201wmg.179.2017.08.25.13.01.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 13:01:49 -0700 (PDT)
Date: Fri, 25 Aug 2017 13:01:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/hmm: struct hmm is only use by HMM mirror
 functionality
Message-Id: <20170825130146.81f28f23a06a22b55270074a@linux-foundation.org>
In-Reply-To: <1503621746-17876-1-git-send-email-jglisse@redhat.com>
References: <20170824230850.1810408-1-arnd@arndb.de>
	<1503621746-17876-1-git-send-email-jglisse@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Stephen Rothwell <sfr@canb.auug.org.au>, Subhash Gutti <sgutti@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>

On Thu, 24 Aug 2017 20:42:26 -0400 jglisse@redhat.com wrote:

> The struct hmm is only use if the HMM mirror functionality is enabled
> move associated code behind CONFIG_HMM_MIRROR to avoid build error if
> one enable some of the HMM memory configuration without the mirror
> feature.

It's unclear whether this patch is in addition to Arnd's "mm: HMM always
needs MMU_NOTIFIER" or is a replacement for it.  (If the latter, it
should have Arnd's Reported-by).  But I cannot get this patch to apply
cleanly in either situation.

So I'll skip both patches.  Please send something which applies on top
of

hmm-heterogeneous-memory-management-documentation-v3.patch
mm-hmm-heterogeneous-memory-management-hmm-for-short-v5.patch
mm-hmm-mirror-mirror-process-address-space-on-device-with-hmm-helpers-v3.patch
mm-hmm-mirror-helper-to-snapshot-cpu-page-table-v4.patch
mm-hmm-mirror-device-page-fault-handler.patch
mm-memory_hotplug-introduce-add_pages.patch
mm-zone_device-new-type-of-zone_device-for-unaddressable-memory-v5.patch
mm-zone_device-new-type-of-zone_device-for-unaddressable-memory-fix.patch
mm-zone_device-special-case-put_page-for-device-private-pages-v4.patch
mm-memcontrol-allow-to-uncharge-page-without-using-page-lru-field.patch
mm-memcontrol-support-memory_device_private-v4.patch
mm-hmm-devmem-device-memory-hotplug-using-zone_device-v7.patch
mm-hmm-devmem-dummy-hmm-device-for-zone_device-memory-v3.patch
mm-migrate-new-migrate-mode-migrate_sync_no_copy.patch
mm-migrate-new-memory-migration-helper-for-use-with-device-memory-v5.patch
mm-migrate-migrate_vma-unmap-page-from-vma-while-collecting-pages.patch
mm-migrate-support-un-addressable-zone_device-page-in-migration-v3.patch
mm-migrate-allow-migrate_vma-to-alloc-new-page-on-empty-entry-v4.patch
mm-device-public-memory-device-memory-cache-coherent-with-cpu-v5.patch
mm-hmm-add-new-helper-to-hotplug-cdm-memory-region-v3.patch
#
mm-hmm-avoid-bloating-arch-that-do-not-make-use-of-hmm.patch

thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

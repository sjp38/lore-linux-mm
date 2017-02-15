Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 97CDB6B040E
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 16:54:48 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id g80so132303678pfb.3
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 13:54:48 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s25si841536pge.40.2017.02.15.13.54.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Feb 2017 13:54:47 -0800 (PST)
Date: Wed, 15 Feb 2017 13:54:46 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC 0/3] Regressions due to 7b79d10a2d64
 ("mm: convert kmalloc_section_memmap() to populate_section_memmap()") and
 Kasan initialization on
Message-Id: <20170215135446.3a299bed01095f4f461870f6@linux-foundation.org>
In-Reply-To: <CAPcyv4gAUCsJ9HcSyAK6j4YDHPkJsb06ZX=uJsYBMDCNMFsNmQ@mail.gmail.com>
References: <20170215205826.13356-1-nicstange@gmail.com>
	<20170215131023.02186e970498eca080c8d456@linux-foundation.org>
	<CAPcyv4gAUCsJ9HcSyAK6j4YDHPkJsb06ZX=uJsYBMDCNMFsNmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Nicolai Stange <nicstange@gmail.com>, Linux MM <linux-mm@kvack.org>

On Wed, 15 Feb 2017 13:26:43 -0800 Dan Williams <dan.j.williams@intel.com> wrote:

> >> The second one, i.e. [2/3], is something that hit my eye while browsing
> >> the source and I verified that this is indeed an issue by printk'ing and
> >> dumping the page tables.
> >>
> >> The third one are excessive warnings from vmemmap_verify() due to Kasan's
> >> NUMA_NO_NODE page populations.
> >
> > urggggh.
> >
> > That means these two series:
> >
> > mm-fix-type-width-of-section-to-from-pfn-conversion-macros.patch
> > mm-devm_memremap_pages-use-multi-order-radix-for-zone_device-lookups.patch
> > mm-introduce-struct-mem_section_usage-to-track-partial-population-of-a-section.patch
> > mm-introduce-common-definitions-for-the-size-and-mask-of-a-section.patch
> > mm-cleanup-sparse_init_one_section-return-value.patch
> > mm-track-active-portions-of-a-section-at-boot.patch
> > mm-track-active-portions-of-a-section-at-boot-fix.patch
> > mm-track-active-portions-of-a-section-at-boot-fix-fix.patch
> > mm-fix-register_new_memory-zone-type-detection.patch
> > mm-convert-kmalloc_section_memmap-to-populate_section_memmap.patch
> > mm-prepare-for-hot-add-remove-of-sub-section-ranges.patch
> > mm-support-section-unaligned-zone_device-memory-ranges.patch
> > mm-support-section-unaligned-zone_device-memory-ranges-fix.patch
> > mm-support-section-unaligned-zone_device-memory-ranges-fix-2.patch
> > mm-enable-section-unaligned-devm_memremap_pages.patch
> > libnvdimm-pfn-dax-stop-padding-pmem-namespaces-to-section-alignment.patch
> >
> 
> Yes, let's drop these and try again for 4.12. Thanks for the report
> and the debug Nicolai!

Please don't lose track of

mm-track-active-portions-of-a-section-at-boot-fix.patch
mm-track-active-portions-of-a-section-at-boot-fix-fix.patch
mm-support-section-unaligned-zone_device-memory-ranges-fix.patch
 mm-support-section-unaligned-zone_device-memory-ranges-fix-2.patch

> > and
> >
> > mm-devm_memremap_pages-hold-device_hotplug-lock-over-mem_hotplug_begin-done.patch
> > mm-validate-device_hotplug-is-held-for-memory-hotplug.patch
> 
> No, these are separate and are still valid for the merge window.

OK.  A bunch of rejects needed fixing.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

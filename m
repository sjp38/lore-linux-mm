Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 311AC6B02C7
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 10:31:49 -0400 (EDT)
Received: by wgbcc4 with SMTP id cc4so65094848wgb.3
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 07:31:48 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id p4si19396264wiz.100.2015.07.21.07.31.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 21 Jul 2015 07:31:47 -0700 (PDT)
Date: Tue, 21 Jul 2015 16:31:12 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH RESEND 2/3] mm, x86: Remove region_is_ram() call from
 ioremap
In-Reply-To: <1437088996-28511-3-git-send-email-toshi.kani@hp.com>
Message-ID: <alpine.DEB.2.11.1507211620250.18576@nanos>
References: <1437088996-28511-1-git-send-email-toshi.kani@hp.com> <1437088996-28511-3-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org, travis@sgi.com, roland@purestorage.com, dan.j.williams@intel.com, mcgrof@suse.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>

On Thu, 16 Jul 2015, Toshi Kani wrote:
> Note, removing the call to region_is_ram() is also necessary to
> fix bugs in region_is_ram().  walk_system_ram_range() requires
> RAM ranges be page-aligned in the iomem_resource table to work
> properly.  This restriction has allowed multiple ioremaps to RAM
> (setup_data) which are page-unaligned.  Using fixed region_is_ram()
> will cause these callers to start failing.

Which callers? 

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

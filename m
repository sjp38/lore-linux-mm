Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id A1A70280340
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 16:37:59 -0400 (EDT)
Received: by wgmn9 with SMTP id n9so90431956wgm.0
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 13:37:59 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id on6si11097294wic.8.2015.07.17.13.37.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 17 Jul 2015 13:37:57 -0700 (PDT)
Date: Fri, 17 Jul 2015 22:37:55 +0200
From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [PATCH v6 0/4] atyfb: atyfb: address MTRR corner case
Message-ID: <20150717203755.GE30479@wotan.suse.de>
References: <1436491499-3289-1-git-send-email-mcgrof@do-not-panic.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1436491499-3289-1-git-send-email-mcgrof@do-not-panic.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Cc: mingo@kernel.org, bp@suse.de, tomi.valkeinen@ti.com, airlied@redhat.com, arnd@arndb.de, dan.j.williams@intel.com, hch@lst.de, luto@amacapital.net, hpa@zytor.com, tglx@linutronix.de, geert@linux-m68k.org, ralf@linux-mips.org, hmh@hmh.eng.br, ross.zwisler@linux.intel.com, akpm@linux-foundation.org, jgross@suse.com, benh@kernel.crashing.org, mpe@ellerman.id.au, tj@kernel.org, x86@kernel.org, mst@redhat.com, toshi.kani@hp.com, stefan.bader@canonical.com, syrjala@sci.fi, ville.syrjala@linux.intel.com, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fbdev@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Jul 09, 2015 at 06:24:55PM -0700, Luis R. Rodriguez wrote:
> From: "Luis R. Rodriguez" <mcgrof@suse.com>
> 
> Ingo,
> 
> Boris is on vacation so sending these through you. This v6 addresses one code
> comment update requested by Ville. Boris had picked up these patches on his
> tree and this series had gone through 0-day bot testing. The only issue it
> found was the lack of ioremap_uc() implementation on some architectures which
> have an IOMMU. There are two approaches to this issue, one is to go and define
> ioremap_uc() on all architectures, another is to provide a default for
> ioremap_uc() as architectures catch up. I've gone with the later approach [0],
> and so to ensure things won't build-break this patch series must also go
> through the same tree as the patch-fixes for ioremap_uc() for missing
> ioremap_uc() implementations go through. I intend on following up with
> implementing ioremap_uc() for other architectures but for that I need to get
> feedback from other architecture developers and that will take time.
> 
> Tomi, the framebuffer maintainer had already expressed he was OK for this to go
> through you. The driver maintainer, Ville, has been Cc'd on all the series, but
> has only provided feedback for the comment request as I noted above. This
> series addresses the more complex work on the entire series I've been putting
> out and as such I've provided a TL;DR full review of what this series does in
> my previous v5 patch series, that can be looked at for more details if needed
> [1].
> 
> This series depends on the patch which I recently posted to address compilation
> issue on architectures missing ioremap_uc() [0]. If that goes through then it
> should be safe to apply this series, otherwise we have to sit and wait until
> all architectures get ioremap_uc() properly defined.
> 
> Please let me know if there are any questions.
> 
> [0] http://lkml.kernel.org/r/1436488096-3165-1-git-send-email-mcgrof@do-not-panic.com
> [1] http://lkml.kernel.org/r/1435196060-27350-1-git-send-email-mcgrof@do-not-panic.com

Ingo, please let me know if there are any questions or issues with this series.

  Luis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

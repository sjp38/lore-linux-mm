Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f44.google.com (mail-yh0-f44.google.com [209.85.213.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8ADBE6B006E
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 10:29:00 -0500 (EST)
Received: by mail-yh0-f44.google.com with SMTP id c41so1481740yho.3
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 07:29:00 -0800 (PST)
Received: from SMTP.CITRIX.COM (smtp.citrix.com. [66.165.176.89])
        by mx.google.com with ESMTPS id q133si3043582yka.13.2015.01.08.07.28.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 Jan 2015 07:28:57 -0800 (PST)
From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCH 2/2] mm: add 'foreign' alias for the 'pinned' page flag
Date: Thu, 8 Jan 2015 15:28:44 +0000
Message-ID: <1420730924-22811-3-git-send-email-david.vrabel@citrix.com>
In-Reply-To: <1420730924-22811-1-git-send-email-david.vrabel@citrix.com>
References: <1420730924-22811-1-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: David Vrabel <david.vrabel@citrix.com>, linux-mm@kvack.org, xen-devel@lists.xenproject.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Jenny Herbert <jennifer.herbert@citrix.com>

From: Jenny Herbert <jennifer.herbert@citrix.com>

The foreign page flag will be used by Xen guests to mark pages that
have grant mappings of frames from other (foreign) guests.

The foreign flag is an alias for the existing (Xen-specific) pinned
flag.  This is safe because pinned is only used on pages used for page
tables and these cannot also be foreign.

Signed-off-by: Jenny Herbert <jennifer.herbert@citrix.com>
Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 include/linux/page-flags.h |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index e1f5fcd..7734cc8 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -123,6 +123,7 @@ enum pageflags {
 	/* XEN */
 	PG_pinned = PG_owner_priv_1,
 	PG_savepinned = PG_dirty,
+	PG_foreign = PG_owner_priv_1,
 
 	/* SLOB */
 	PG_slob_free = PG_private,
@@ -215,6 +216,7 @@ __PAGEFLAG(Slab, slab)
 PAGEFLAG(Checked, checked)		/* Used by some filesystems */
 PAGEFLAG(Pinned, pinned) TESTSCFLAG(Pinned, pinned)	/* Xen */
 PAGEFLAG(SavePinned, savepinned);			/* Xen */
+PAGEFLAG(Foreign, foreign);				/* Xen */
 PAGEFLAG(Reserved, reserved) __CLEARPAGEFLAG(Reserved, reserved)
 PAGEFLAG(SwapBacked, swapbacked) __CLEARPAGEFLAG(SwapBacked, swapbacked)
 	__SETPAGEFLAG(SwapBacked, swapbacked)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

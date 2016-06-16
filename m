Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id ABD0C6B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 19:11:23 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id s63so120572352ioi.1
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 16:11:23 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 69si8437379pfr.155.2016.06.16.16.11.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 16:11:23 -0700 (PDT)
Date: Thu, 16 Jun 2016 16:11:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] mm: Don't blindly assign fallback_migrate_page()
Message-Id: <20160616161121.35ee5183b9ef9f7b7dcbc815@linux-foundation.org>
In-Reply-To: <1466112375-1717-2-git-send-email-richard@nod.at>
References: <1466112375-1717-1-git-send-email-richard@nod.at>
	<1466112375-1717-2-git-send-email-richard@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-mtd@lists.infradead.org, hannes@cmpxchg.org, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, hughd@google.com, vbabka@suse.cz, adrian.hunter@intel.com, dedekind1@gmail.com, hch@infradead.org, linux-fsdevel@vger.kernel.org, boris.brezillon@free-electrons.com, maxime.ripard@free-electrons.com, david@sigma-star.at, david@fromorbit.com, alex@nextthing.co, sasha.levin@oracle.com, iamjoonsoo.kim@lge.com, rvaswani@codeaurora.org, tony.luck@intel.com, shailendra.capricorn@gmail.com

On Thu, 16 Jun 2016 23:26:13 +0200 Richard Weinberger <richard@nod.at> wrote:

> While block oriented filesystems use buffer_migrate_page()
> as page migration function other filesystems which don't
> implement ->migratepage() will automatically get fallback_migrate_page()
> assigned. fallback_migrate_page() is not as generic as is should
> be. Page migration is filesystem specific and a one-fits-all function
> is hard to achieve. UBIFS leaned this lection the hard way.
> It uses various page flags and fallback_migrate_page() does not
> handle these flags as UBIFS expected.
> 
> To make sure that no further filesystem will get confused by
> fallback_migrate_page() disable the automatic assignment and
> allow filesystems to use this function explicitly if it is
> really suitable.

hm, is there really much point in doing this?  I assume it doesn't
actually affect any current filesystems?

[2/3] is of course OK - please add it to the UBIFS tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id BE0AF6B0081
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 16:40:39 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so3960252pad.14
        for <linux-mm@kvack.org>; Mon, 19 Nov 2012 13:40:39 -0800 (PST)
Date: Mon, 19 Nov 2012 13:40:37 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 29/58] mm: Make copy_pte_range static
In-Reply-To: <1353302917-13995-30-git-send-email-josh@joshtriplett.org>
Message-ID: <alpine.DEB.2.00.1211191340170.12532@chino.kir.corp.google.com>
References: <1353302917-13995-1-git-send-email-josh@joshtriplett.org> <1353302917-13995-30-git-send-email-josh@joshtriplett.org>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531381512-846407968-1353361238=:12532"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Triplett <josh@joshtriplett.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Al Viro <viro@zeniv.linux.org.uk>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531381512-846407968-1353361238=:12532
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Sun, 18 Nov 2012, Josh Triplett wrote:

> Nothing outside of mm/memory.c references copy_pte_range.
> linux/huge_mm.h prototypes it, but nothing uses that prototype.  Commit
> 71e3aac0724ffe8918992d76acfe3aad7d8724a5 in January 2011 explicitly made
> copy_pte_range non-static, but no commit ever introduced a caller for
> copy_pte_range outside of mm/memory.c.  Make the function static.
> 
> This eliminates a warning from gcc (-Wmissing-prototypes) and from
> Sparse (-Wdecl).
> 
> mm/memory.c:917:5: warning: no previous prototype for a??copy_pte_rangea?? [-Wmissing-prototypes]
> 
> Signed-off-by: Josh Triplett <josh@joshtriplett.org>

Acked-by: David Rientjes <rientjes@google.com>
--531381512-846407968-1353361238=:12532--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

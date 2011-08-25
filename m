Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A79FE6B016A
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 10:23:54 -0400 (EDT)
Date: Thu, 25 Aug 2011 09:23:50 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH -mmotm] lib/string.c: fix kernel-doc for memchr_inv
In-Reply-To: <1314281680-21553-1-git-send-email-akinobu.mita@gmail.com>
Message-ID: <alpine.DEB.2.00.1108250923350.27407@router.home>
References: <1314281680-21553-1-git-send-email-akinobu.mita@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Akinobu Mita <akinobu.mita@gmail.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, Geert Uytterhoeven <geert@linux-m68k.org>

On Thu, 25 Aug 2011, Akinobu Mita wrote:

> This fixes kernel-doc for memchr_inv() which is introduced by
> lib-stringc-introduce-memchr_inv.patch in mmotm 2011-08-24-14-08

Reviewed-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

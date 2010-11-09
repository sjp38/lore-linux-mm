Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7FBA96B0071
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 11:03:24 -0500 (EST)
Date: Tue, 9 Nov 2010 10:03:20 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Fix slub_lock down/up imbalance
In-Reply-To: <4CD80BDE.4040809@parallels.com>
Message-ID: <alpine.DEB.2.00.1011091003020.9898@router.home>
References: <4CC9476D.7050006@parallels.com> <alpine.DEB.2.00.1010280839470.25874@router.home> <4CD80BDE.4040809@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 8 Nov 2010, Pavel Emelyanov wrote:

> Gentlemen, I believe you've been very busy these days, but can
> you please share with me what are your plans about this patch?

Pekka is going to merge it as far as I can tell.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

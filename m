Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3C4D38D0015
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 09:44:56 -0400 (EDT)
Date: Thu, 28 Oct 2010 08:44:53 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Fix slub_lock down/up imbalance
In-Reply-To: <4CC9476D.7050006@parallels.com>
Message-ID: <alpine.DEB.2.00.1010280839470.25874@router.home>
References: <4CC9476D.7050006@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 28 Oct 2010, Pavel Emelyanov wrote:

> There are two places, that do not release the slub_lock.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 820E66B004A
	for <linux-mm@kvack.org>; Mon,  8 Nov 2010 10:05:45 -0500 (EST)
Message-ID: <4CD80BDE.4040809@parallels.com>
Date: Mon, 08 Nov 2010 17:40:30 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slub: Fix slub_lock down/up imbalance
References: <4CC9476D.7050006@parallels.com> <alpine.DEB.2.00.1010280839470.25874@router.home>
In-Reply-To: <alpine.DEB.2.00.1010280839470.25874@router.home>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Matt Mackall <mpm@selenic.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 10/28/2010 05:44 PM, Christoph Lameter wrote:
> On Thu, 28 Oct 2010, Pavel Emelyanov wrote:
> 
>> There are two places, that do not release the slub_lock.
> 
> Acked-by: Christoph Lameter <cl@linux.com>
> 

Thanks!

Gentlemen, I believe you've been very busy these days, but can
you please share with me what are your plans about this patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

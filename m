Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 70EB36B0105
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 15:32:12 -0400 (EDT)
Date: Tue, 28 Jun 2011 14:32:08 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: reduce overhead of slub_debug
In-Reply-To: <20110626193918.GA3339@joi.lan>
Message-ID: <alpine.DEB.2.00.1106281431370.27518@router.home>
References: <20110626193918.GA3339@joi.lan>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcin Slusarz <marcin.slusarz@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Sun, 26 Jun 2011, Marcin Slusarz wrote:

> slub checks for poison one byte by one, which is highly inefficient
> and shows up frequently as a highest cpu-eater in perf top.

Ummm.. Performance improvements for debugging modes? If you need
performance then switch off debuggin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

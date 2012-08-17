Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 51B876B005D
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 07:32:26 -0400 (EDT)
Received: by lahd3 with SMTP id d3so2418455lah.14
        for <linux-mm@kvack.org>; Fri, 17 Aug 2012 04:32:24 -0700 (PDT)
Date: Fri, 17 Aug 2012 14:32:22 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [patch] mm, slab: remove dflags
In-Reply-To: <000001393190efa8-08cba91b-1bf6-4d31-8b0c-f3864bbe26b0-000000@email.amazonses.com>
Message-ID: <alpine.LFD.2.02.1208171432110.2553@tux.localdomain>
References: <alpine.DEB.2.00.1208161225480.28427@chino.kir.corp.google.com> <000001393190efa8-08cba91b-1bf6-4d31-8b0c-f3864bbe26b0-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On Thu, 16 Aug 2012, David Rientjes wrote:
> > cachep->dflags is never referenced, so remove it.

On Thu, 16 Aug 2012, Christoph Lameter wrote:
> Acked-by: Christoph Lameter <cl@linux.com>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Message-ID: <481A3586.3080705@cs.helsinki.fi>
Date: Fri, 02 May 2008 00:26:30 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH] slub: #ifdef simplification
References: <Pine.LNX.4.64.0804291615130.15436@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0804291615130.15436@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> [Rediffed to current git]
> 
> If we make SLUB_DEBUG depend on SYSFS then we can simplify some
> #ifdefs and avoid others.

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

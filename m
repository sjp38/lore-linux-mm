Message-ID: <48144EDA.3090407@cs.helsinki.fi>
Date: Sun, 27 Apr 2008 13:00:58 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: slub: #ifdef simplification
References: <Pine.LNX.4.64.0804251222570.5971@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0804251222570.5971@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> If we make SLUB_DEBUG depend on SYSFS then we can simplify some
> #ifdefs and avoid others.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

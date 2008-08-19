Received: by gxk8 with SMTP id 8so6125431gxk.14
        for <linux-mm@kvack.org>; Tue, 19 Aug 2008 12:08:20 -0700 (PDT)
Date: Tue, 19 Aug 2008 22:05:06 +0300
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: Re: [PATCH 3/5] SLUB: Replace __builtin_return_address(0) with
	_RET_IP_.
Message-ID: <20080819190506.GC5520@localhost>
References: <1219167807-5407-1-git-send-email-eduard.munteanu@linux360.ro> <1219167807-5407-2-git-send-email-eduard.munteanu@linux360.ro> <1219167807-5407-3-git-send-email-eduard.munteanu@linux360.ro> <48AB0D69.4090703@linux-foundation.org> <20080819182423.GA5520@localhost> <48AB1769.3040703@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48AB1769.3040703@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: penberg@cs.helsinki.fi, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rdunlap@xenotime.net, mpm@selenic.com, tglx@linutronix.de, rostedt@goodmis.org, mathieu.desnoyers@polymtl.ca, tzanussi@gmail.com
List-ID: <linux-mm.kvack.org>

On Tue, Aug 19, 2008 at 01:56:41PM -0500, Christoph Lameter wrote:

> Well maybe this patch will do it then:
> 
> Subject: slub: Use _RET_IP and use "unsigned long" for kernel text addresses
> 
> Use _RET_IP_ instead of buildint_return_address() and make slub use unsigned long
> instead of void * for addresses.
> 
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> 
> ---
>  mm/slub.c |   46 +++++++++++++++++++++++-----------------------
>  1 file changed, 23 insertions(+), 23 deletions(-)

It seems Pekka just submitted something like this. Though I think using 0L
should be replaced with 0UL to be fully correct.

Pekka, should I test one of these variants and resubmit, or will you
merge it by yourself?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

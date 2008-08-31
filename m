Message-ID: <48BAAC3C.4050309@cs.helsinki.fi>
Date: Sun, 31 Aug 2008 17:35:40 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH] kmemtrace: SLUB hooks for caller-tracking functions.
References: <1219600175-5253-1-git-send-email-eduard.munteanu@linux360.ro>
In-Reply-To: <1219600175-5253-1-git-send-email-eduard.munteanu@linux360.ro>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rdunlap@xenotime.net, mpm@selenic.com, tglx@linutronix.de, rostedt@goodmis.org, cl@linux-foundation.org, mathieu.desnoyers@polymtl.ca, tzanussi@gmail.com
List-ID: <linux-mm.kvack.org>

Eduard - Gabriel Munteanu wrote:
> This patch adds kmemtrace hooks for __kmalloc_track_caller() and
> __kmalloc_node_track_caller(). Currently, they set the call site pointer
> to the value recieved as a parameter. (This could change if we implement
> stack trace exporting in kmemtrace.)
> 
> Signed-off-by: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>

Applied. I had to do some manual tweaking, so can you please 
double-check the result:

http://git.kernel.org/?p=linux/kernel/git/penberg/slab-2.6.git;a=commitdiff;h=b9f1ecc6428f0ba391845b2ac7df8618da287e4f

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

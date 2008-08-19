Message-ID: <48AB1DE2.30402@cs.helsinki.fi>
Date: Tue, 19 Aug 2008 22:24:18 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH 2/5] kmemtrace: Better alternative to "kmemtrace: fix
 printk format warnings".
References: <1219167807-5407-1-git-send-email-eduard.munteanu@linux360.ro> <1219167807-5407-2-git-send-email-eduard.munteanu@linux360.ro>
In-Reply-To: <1219167807-5407-2-git-send-email-eduard.munteanu@linux360.ro>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rdunlap@xenotime.net, mpm@selenic.com, tglx@linutronix.de, rostedt@goodmis.org, cl@linux-foundation.org, mathieu.desnoyers@polymtl.ca, tzanussi@gmail.com
List-ID: <linux-mm.kvack.org>

Eduard - Gabriel Munteanu wrote:
> Fix the problem "kmemtrace: fix printk format warnings" attempted to fix,
> but resulted in marker-probe format mismatch warnings. Instead of carrying
> size_t into probes, we get rid of it by casting to unsigned long, just as
> we did with gfp_t.
> 
> This way, we don't need to change marker format strings and we don't have
> to rely on other format specifiers like "%zu", making for consistent use
> of more generic data types (since there are no format specifiers for
> gfp_t, for example).
> 
> Signed-off-by: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

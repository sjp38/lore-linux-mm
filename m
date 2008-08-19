Message-ID: <48AB1A8A.9010007@cs.helsinki.fi>
Date: Tue, 19 Aug 2008 22:10:02 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] kmemtrace: SLUB hooks.
References: <1219167807-5407-1-git-send-email-eduard.munteanu@linux360.ro> <1219167807-5407-2-git-send-email-eduard.munteanu@linux360.ro> <1219167807-5407-3-git-send-email-eduard.munteanu@linux360.ro> <1219167807-5407-4-git-send-email-eduard.munteanu@linux360.ro>
In-Reply-To: <1219167807-5407-4-git-send-email-eduard.munteanu@linux360.ro>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rdunlap@xenotime.net, mpm@selenic.com, tglx@linutronix.de, rostedt@goodmis.org, cl@linux-foundation.org, mathieu.desnoyers@polymtl.ca, tzanussi@gmail.com
List-ID: <linux-mm.kvack.org>

Eduard - Gabriel Munteanu wrote:
> This adds hooks for the SLUB allocator, to allow tracing with kmemtrace.
> 
> Signed-off-by: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

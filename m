Message-ID: <48AB1EA2.4070904@cs.helsinki.fi>
Date: Tue, 19 Aug 2008 22:27:30 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] Revert "kmemtrace: fix printk format warnings"
References: <1219167807-5407-1-git-send-email-eduard.munteanu@linux360.ro>
In-Reply-To: <1219167807-5407-1-git-send-email-eduard.munteanu@linux360.ro>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rdunlap@xenotime.net, mpm@selenic.com, tglx@linutronix.de, rostedt@goodmis.org, cl@linux-foundation.org, mathieu.desnoyers@polymtl.ca, tzanussi@gmail.com
List-ID: <linux-mm.kvack.org>

Eduard - Gabriel Munteanu wrote:
> This reverts commit 79cf3d5e207243eecb1c4331c569e17700fa08fa.
> 
> The reverted commit, while it fixed printk format warnings, it resulted in
> marker-probe format mismatches. Another approach should be used to fix
> these warnings.

I simply dropped Randy's patch so the revert wasn't needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Message-ID: <48AB1A5B.3020305@cs.helsinki.fi>
Date: Tue, 19 Aug 2008 22:09:15 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] SLUB: Replace __builtin_return_address(0) with	_RET_IP_.
References: <1219167807-5407-1-git-send-email-eduard.munteanu@linux360.ro> <1219167807-5407-2-git-send-email-eduard.munteanu@linux360.ro> <1219167807-5407-3-git-send-email-eduard.munteanu@linux360.ro> <48AB0D69.4090703@linux-foundation.org> <20080819182423.GA5520@localhost> <48AB1769.3040703@linux-foundation.org>
In-Reply-To: <48AB1769.3040703@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rdunlap@xenotime.net, mpm@selenic.com, tglx@linutronix.de, rostedt@goodmis.org, mathieu.desnoyers@polymtl.ca, tzanussi@gmail.com
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
>  static void print_track(const char *s, struct track *t)
> @@ -399,7 +399,7 @@ static void print_track(const char *s, s
>  	if (!t->addr)
>  		return;
> 
> -	printk(KERN_ERR "INFO: %s in %pS age=%lu cpu=%u pid=%d\n",
> +	printk(KERN_ERR "INFO: %s in %lxS age=%lu cpu=%u pid=%d\n",
>  		s, t->addr, jiffies - t->when, t->cpu, t->pid);

This looks wrong. The '%pS' thingy has a special purpose:

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=7daf705f362e349983e92037a198b8821db198af

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

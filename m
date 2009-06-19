Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B40946B0092
	for <linux-mm@kvack.org>; Fri, 19 Jun 2009 21:20:56 -0400 (EDT)
Subject: Re: [PATCH] kmemleak: use pr_fmt
From: Joe Perches <joe@perches.com>
In-Reply-To: <1245405220.12653.25.camel@pc1117.cambridge.arm.com>
References: <1245341337.29927.8.camel@Joe-Laptop.home>
	 <1245405220.12653.25.camel@pc1117.cambridge.arm.com>
Content-Type: text/plain
Date: Fri, 19 Jun 2009 12:49:42 -0700
Message-Id: <1245440992.6201.17.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2009-06-19 at 10:53 +0100, Catalin Marinas wrote:
> Thanks for the patch. It missed one pr_info case (actually invoked via
> the pr_helper macro).

This change will affect the seq_printf uses.
Some think the seq output should be immutable.
Perhaps that's important to you or others.

An option is to change the print_helper
pr_info to a printk(KERN_INFO and not change
any uses of print_helper

#define print_helper(seq, x...)	do {	\
	struct seq_file *s = (seq);	\
	if (s)				\
		seq_printf(s, x);	\
	else				\
		printk(KERN_INFO x);	\
} while (0)

> > +#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> > + 
>    ^ - empty space at the end of the line (git told me about it)

Thanks for letting me know.  I'll fix my tools.

Joe


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

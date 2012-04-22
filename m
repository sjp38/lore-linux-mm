Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 4D1E96B00E8
	for <linux-mm@kvack.org>; Sun, 22 Apr 2012 15:22:17 -0400 (EDT)
Date: Sun, 22 Apr 2012 15:22:10 -0400 (EDT)
Message-Id: <20120422.152210.1520263792125579554.davem@davemloft.net>
Subject: Re: Weirdness in __alloc_bootmem_node_high
From: David Miller <davem@davemloft.net>
In-Reply-To: <20120420194309.GA3689@merkur.ravnborg.org>
References: <20120420191418.GA3569@merkur.ravnborg.org>
	<CAE9FiQU-M0yW_rwysq56zrZzift=PxgwioMmx8bMcJ5o20m2TQ@mail.gmail.com>
	<20120420194309.GA3689@merkur.ravnborg.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sam@ravnborg.org
Cc: yinghai@kernel.org, tj@kernel.org, mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Sam Ravnborg <sam@ravnborg.org>
Date: Fri, 20 Apr 2012 21:43:09 +0200

> I have it almost finished - except that it does not work :-(
> We have limitations in what area we can allocate very early,
> and here I had to use the alloc_bootmem_low() variant.
> I had preferred a variant that allowed me to allocate
> bottom-up in this case.

I think you're going to have to bear down and map all of linear kernel
mappings before you start using the bootmem code rather than
afterwards.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

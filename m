Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na6sys010bmx057.postini.com [74.125.246.157])
	by kanga.kvack.org (Postfix) with SMTP id 7EDB26B00A3
	for <linux-mm@kvack.org>; Mon, 25 Mar 2013 17:26:32 -0400 (EDT)
Date: Mon, 25 Mar 2013 14:26:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm: speedup in __early_pfn_to_nid
Message-Id: <20130325142630.faf41b11416c2e4ac3d61550@linux-foundation.org>
In-Reply-To: <20130321180321.GB4185@gmail.com>
References: <20130318155619.GA18828@sgi.com>
	<20130321105516.GC18484@gmail.com>
	<20130321123505.GA6051@dhcp22.suse.cz>
	<20130321180321.GB4185@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, Russ Anderson <rja@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com

On Thu, 21 Mar 2013 19:03:21 +0100 Ingo Molnar <mingo@kernel.org> wrote:

> > IMO the local scope is more obvious as this is and should only be used 
> > for caching purposes.
> 
> It's a pattern we actively avoid in kernel code.

On the contrary, I always encourage people to move the static
definitions into function scope if possible.  So the reader can see the
identifier's scope without having to search the whole file. 
Unnecessarily giving the identifier file-scope seems weird.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

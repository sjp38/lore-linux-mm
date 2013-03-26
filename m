Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 5232A6B00C8
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 04:05:50 -0400 (EDT)
Received: by mail-ee0-f53.google.com with SMTP id c13so874127eek.40
        for <linux-mm@kvack.org>; Tue, 26 Mar 2013 01:05:48 -0700 (PDT)
Date: Tue, 26 Mar 2013 09:05:45 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [patch] mm: speedup in __early_pfn_to_nid
Message-ID: <20130326080545.GA26852@gmail.com>
References: <20130318155619.GA18828@sgi.com>
 <20130321105516.GC18484@gmail.com>
 <20130321123505.GA6051@dhcp22.suse.cz>
 <20130321180321.GB4185@gmail.com>
 <20130325142630.faf41b11416c2e4ac3d61550@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130325142630.faf41b11416c2e4ac3d61550@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Russ Anderson <rja@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com


* Andrew Morton <akpm@linux-foundation.org> wrote:

> On Thu, 21 Mar 2013 19:03:21 +0100 Ingo Molnar <mingo@kernel.org> wrote:
> 
> > > IMO the local scope is more obvious as this is and should only be 
> > > used for caching purposes.
> > 
> > It's a pattern we actively avoid in kernel code.
> 
> On the contrary, I always encourage people to move the static 
> definitions into function scope if possible.  So the reader can see the 
> identifier's scope without having to search the whole file. 
> Unnecessarily giving the identifier file-scope seems weird.

A common solution I use is to move such variables right before the 
function itself. That makes the "this function's scope only" aspect pretty 
apparent - without the risks of hiding globals amongst local variables. 

The other approach is to comment the variables very clearly that they are 
really globals as the 'static' keyword is easy to miss while reading 
email.

Both solutions are basically just as visible as the solution you prefer - 
but more robust.

Anyway, I guess we have to agree to disagree on that, we probably already 
spent more energy on discussing this than any worst-case problem the 
placement of these variables could ever cause in the future ;-)

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

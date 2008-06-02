Date: Mon, 2 Jun 2008 12:15:30 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 3/5] x86: lockless get_user_pages_fast
Message-ID: <20080602101530.GA7206@wotan.suse.de>
References: <20080529122050.823438000@nick.local0.net> <20080529122602.330656000@nick.local0.net> <1212081659.6308.10.camel@norville.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1212081659.6308.10.camel@norville.austin.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

BTW. I do plan to ask Linus to merge this as soon as 2.6.27 opens.
Hope nobody objects (or if they do please speak up before then)


On Thu, May 29, 2008 at 12:20:59PM -0500, Dave Kleikamp wrote:
> On Thu, 2008-05-29 at 22:20 +1000, npiggin@suse.de wrote:
>  
> > +int get_user_pages_fast(unsigned long start, int nr_pages, int write, struct page **pages)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

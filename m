Date: Wed, 23 Nov 2005 09:03:34 -0800 (PST)
From: Christoph Lameter <christoph@lameter.com>
Subject: Re: [PATCH]: Free pages from local pcp lists under tight memory
 conditions
In-Reply-To: <Pine.LNX.4.64.0511230834160.13959@g5.osdl.org>
Message-ID: <Pine.LNX.4.62.0511230857260.11339@graphe.net>
References: <20051122161000.A22430@unix-os.sc.intel.com>
 <20051122213612.4adef5d0.akpm@osdl.org> <Pine.LNX.4.62.0511222238530.2084@graphe.net>
 <Pine.LNX.4.64.0511230834160.13959@g5.osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, Rohit Seth <rohit.seth@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 23 Nov 2005, Linus Torvalds wrote:

> On Tue, 22 Nov 2005, Christoph Lameter wrote:
> > On Tue, 22 Nov 2005, Andrew Morton wrote:
> > > +extern int drain_local_pages(void);
> > drain_cpu_pcps?
> 
> Please no.
> 
> If there is something I _hate_ it's bad naming. And "pcps" is a totally 
> unintelligible name.
> 
> Write it out. If a function is so trivial that you can't be bothered to 
> write out what the name means, that function shouldn't exist at all. 
> Conversely, if it's worth doing, it's worth writing out a name.


drain_one_cpus_pages_from_per_cpu_pagesets()

drain_one_cpus_remote_pages_from_per_cpu_pagesets()

drain_all_per_cpu_pagesets()

?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

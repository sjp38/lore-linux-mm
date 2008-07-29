Date: Mon, 28 Jul 2008 20:03:11 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: PERF: performance tests with the split LRU VM in -mm
Message-ID: <20080728200311.2218af4e@cuia.bos.redhat.com>
In-Reply-To: <20080728195713.42cbceed@cuia.bos.redhat.com>
References: <20080724222510.3bbbbedc@bree.surriel.com>
	<20080728105742.50d6514e@cuia.bos.redhat.com>
	<20080728164124.8240eabe.akpm@linux-foundation.org>
	<20080728195713.42cbceed@cuia.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jul 2008 19:57:13 -0400
Rik van Riel <riel@redhat.com> wrote:
> On Mon, 28 Jul 2008 16:41:24 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > > Andrew, what is your preference between:
> > > 	http://lkml.org/lkml/2008/7/15/465
> > > and
> > > 	http://marc.info/?l=linux-mm&m=121683855132630&w=2
> > > 
> > 
> > Boy.  They both seem rather hacky special-cases.  But that doesn't mean
> > that they're undesirable hacky special-cases.  I guess the second one
> > looks a bit more "algorithmic" and a bit less hacky-special-case.  But
> > it all depends on testing..
> 
> I prefer the second one, since it removes the + 1 magic (at least,
> for the higher priorities), instead of adding new magic like the
> other patch does.

Btw, didn't you add that "+ 1" originally early on in the 2.6 VM?

Do you remember its purpose?  

Does it still make sense to have that "+ 1" in the split LRU VM?

Could we get away with just removing it unconditionally?

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

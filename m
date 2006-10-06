Date: Thu, 5 Oct 2006 17:47:48 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: NOPAGE_RETRY and 2.6.19
Message-Id: <20061005174748.528a3bba.akpm@osdl.org>
In-Reply-To: <1160091499.22232.98.camel@localhost.localdomain>
References: <1160088050.22232.90.camel@localhost.localdomain>
	<20061005160634.5932ba78.akpm@osdl.org>
	<1160091499.22232.98.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 06 Oct 2006 09:38:19 +1000
Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> On Thu, 2006-10-05 at 16:06 -0700, Andrew Morton wrote:
> > On Fri, 06 Oct 2006 08:40:50 +1000
> > Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
> > 
> > > Any chance that can be merged in 2.6.19 ?
> > 
> > Not if you don't show it to anyone ;)
> 
> Didn' I send it to you last week ?

I saw a little dribble of diff at the end of some email thread, but unless it
fixes some bug which I want to fix I'll generally ignore dribbly diffs and
wait for the real patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Get rid of zone_table V2
Date: Tue, 19 Sep 2006 20:24:54 +0200
References: <Pine.LNX.4.64.0609181215120.20191@schroedinger.engr.sgi.com> <45101EAE.2070303@yahoo.com.au> <Pine.LNX.4.64.0609191049250.5879@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0609191049250.5879@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200609192024.54477.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tuesday 19 September 2006 19:50, Christoph Lameter wrote:
> On Wed, 20 Sep 2006, Nick Piggin wrote:
> 
> > BTW. I wonder why gcc isn't using two shifts in your example? Not that
> > I think it would be great even if it were, because subtle differences
> > could cause that to become more shifts...
> 
> Perhaps multiply is highly optimized in contemporary processors and I am 
> worrying too much about the multiply?

It is. e.g. an Opteron can do a multiply in 3-4 cycles

Just arbitary division is still slow. Division by constant is usually
also not that bad because the compiler can decompose it into multiplies
and other operations.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

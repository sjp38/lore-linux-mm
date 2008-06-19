From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: Can get_user_pages( ,write=1, force=1, ) result in a read-only pte and _count=2?
Date: Thu, 19 Jun 2008 22:21:33 +1000
References: <20080618164158.GC10062@sgi.com> <Pine.LNX.4.64.0806191209370.7324@blonde.site> <200806192207.40838.nickpiggin@yahoo.com.au>
In-Reply-To: <200806192207.40838.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200806192221.34103.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Robin Holt <holt@sgi.com>, Ingo Molnar <mingo@elte.hu>, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 19 June 2008 22:07, Nick Piggin wrote:
> On Thursday 19 June 2008 21:39, Hugh Dickins wrote:

> > I probably won't get back to this today.  And there are also good
> > reasons in -mm for me to check back on all these swapcount issues.
>
> I don't see how you can get an accurate page_swapcount without
> the page lock. Anyway, if you volunteer to take a look at the
> problem, great. I expect Robin could just as well fix it for
> their code in the meantime by using force=0...

You could always use another page flag, of course ;)
Or get rid of Linus pages

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

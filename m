From: Daniel Phillips <phillips@arcor.de>
Subject: Re: Non-GPL export of invalidate_mmap_range
Date: Fri, 20 Feb 2004 18:00:32 -0500
References: <20040216190927.GA2969@us.ibm.com> <200402201535.47848.phillips@arcor.de> <20040220140116.GD1269@us.ibm.com>
In-Reply-To: <20040220140116.GD1269@us.ibm.com>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200402201800.12077.phillips@arcor.de>
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: paulmck@us.ibm.com
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Andrew Morton <akpm@osdl.org>, Christoph Hellwig <hch@infradead.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Friday 20 February 2004 09:01, Paul E. McKenney wrote:
> On Fri, Feb 20, 2004 at 03:37:26PM -0500, Daniel Phillips wrote:
> > Actually, I erred there in that invalidate_mmap_range should not export
> > the flag, because it never makes sense to pass in non-zero from a DFS.
>
> Doesn't vmtruncate() want to pass non-zero "all" in to
> invalidate_mmap_range() in order to maintain compatibility with existing
> Linux semantics?

That comes from inside.  The DFS's truncate interface should just be 
vmtruncate.  If I missed something, please shout.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [RFC][PATCH] Avoid vmtruncate/mmap-page-fault race
Date: Fri, 23 May 2003 19:10:58 +0200
References: <Pine.LNX.4.44.0305231713230.1602-100000@localhost.localdomain>
In-Reply-To: <Pine.LNX.4.44.0305231713230.1602-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200305231910.58743.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
Cc: Andrew Morton <akpm@digeo.com>, hch@infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Friday 23 May 2003 18:21, Hugh Dickins wrote:
> Sorry, I miss the point of this patch entirely.  At the moment it just
> looks like an unattractive rearrangement - the code churn akpm advised
> against - with no bearing on that vmtruncate race.  Please correct me.

This is all about supporting cross-host mmap (nice trick, huh?).  Yes, 
somebody should post a detailed rfc on that subject.

Regards,

Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Date: Wed, 25 Feb 2004 11:14:16 -0800
From: "Paul E. McKenney" <paulmck@us.ibm.com>
Subject: Re: [RFC] Distributed mmap API
Message-ID: <20040225191416.GE1397@us.ibm.com>
Reply-To: paulmck@us.ibm.com
References: <20040216190927.GA2969@us.ibm.com> <200402211400.16779.phillips@arcor.de> <20040222233911.GB1311@us.ibm.com> <200402251604.19040.phillips@arcor.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200402251604.19040.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Andrew Morton <akpm@osdl.org>, Christoph Hellwig <hch@infradead.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 25, 2004 at 04:04:19PM -0500, Daniel Phillips wrote:
>
> I'd like to take this opportunity to apologize to Paul for derailing his more
> modest proposal, but unfortunately, the semantics that could be obtained that
> way are fatally flawed: private mmaps just won't work.  What I've written here
> is about the minimum that supports acceptable mmap semantics.

No problem -- it looks like we are getting a much better result than
I was proposing, thank you for helping me to see the light!

						Thanx, Paul
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

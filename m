Date: Thu, 15 May 2003 02:55:39 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: Race between vmtruncate and mapped areas?
Message-Id: <20030515025539.0067012d.akpm@digeo.com>
In-Reply-To: <20030515094656.GB1429@dualathlon.random>
References: <20030515004915.GR1429@dualathlon.random>
	<Pine.LNX.4.44.0305142234120.20800-100000@chimarrao.boston.redhat.com>
	<20030515094656.GB1429@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: riel@redhat.com, dmccr@us.ibm.com, mika.penttila@kolumbus.fi, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli <andrea@suse.de> wrote:
>
> > > -	if (page->buffers)
>  > > -		goto preserve;
>  > > +	BUG_ON(page->buffers);
>  > 
>  > I wonder if there is nothing else that can leave behind
>  > buffers in this way.
> 
>  that's why I left the BUG_ON, if there's anything else I want to know,
>  there shouldn't be anything else as the comment also suggest. I recall
>  when we discussed this single check with Andrew and that was the only
>  reason we left it AFIK.

yes, the test should no longer be needed.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

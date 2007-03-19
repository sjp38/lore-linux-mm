Date: Mon, 19 Mar 2007 10:04:10 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: ZERO_PAGE refcounting causes cache line bouncing
In-Reply-To: <45FE261F.3030903@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0703191002100.23929@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0703161514170.7846@schroedinger.engr.sgi.com>
 <20070317043545.GH8915@holomorphy.com> <45FE261F.3030903@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 19 Mar 2007, Nick Piggin wrote:

> I've always thought the bouncing issue was a silly one and should be
> fixed, of course. Maybe the reason my fix was vetoed was lack of numbers.
> Christoph, would you oblige? I'll dig out the patch and repost.

Well this occurs on a 1024p system that is only sporadically available. It 
gets so bad it hangs completely. Could you also provide patch against 
SLES10? We get get some bug action on this one I think.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

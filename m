Date: Tue, 30 Jul 2002 09:52:04 -0700
From: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Reply-To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Subject: Re: [RFC] start_aggressive_readahead
Message-ID: <646802512.1028022723@[10.10.2.3]>
In-Reply-To: <D4FAAB57-A3DA-11D6-9922-000393829FA4@cs.amherst.edu>
References: <D4FAAB57-A3DA-11D6-9922-000393829FA4@cs.amherst.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Scott Kaplan <sfkaplan@cs.amherst.edu>
Cc: Andrew Morton <akpm@zip.com.au>, Rik van Riel <riel@conectiva.com.br>, Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> Thus I'd contend that either growing or shrinking in straight
>> response to just a hit/miss rate is not correct. We need to actually
>> look at the access pattern of the application, surely?
> 
> I agree.  I probably should have made it clear that what I was 
> suggesting wasn't the right way to go about it, but rather an 
> argument against the heuristics that seemed backwards to me.

Both sets of heuristics seem backwards to me, depending on the
circumstances ;-)

> The causes for misses are necessarily as clear cut as you 
> mentioned, as there are a lot of behaviors that are neither 
> fully random nor fully sequential. 

Indeed. Sorry - all I was trying to point out was that if there
exist two identical sets of input data that can lead two different
correct sets of output data, the calculation you're doing is
insufficient. Of course, there are many more than two circumstances.

> So, while it is ideal to have some foresight before resizing the 
> window -- some calculation that determines whether or not growth 
> will help or shrinkage will hurt -- it will require the VM system
> to gather hit distributions.  

Yup, but I think it's almost certainly worth that expense.

> However, the paper for which I gave a pointer (in a shameless act 
> of self promotion) proposes exactly that:  Keeping reference 

I should read that ;-) We seem to be mostly in violent agreement ...
How you actually calculate the window is a matter for debate and
experimentation, but just growing and shrinking based on purely the 
hit rate seems like a bad idea.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

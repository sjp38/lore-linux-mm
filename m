Date: Wed, 22 Jan 2003 09:56:48 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: What does pkmap stand for?
Message-ID: <148890000.1043258207@titus>
In-Reply-To: <Pine.LNX.4.44.0301221744080.2402-100000@skynet>
References: <Pine.LNX.4.44.0301221744080.2402-100000@skynet>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Really stupid question I know. I'm writing the chapter on high memory
> management and so far it is making perfect sense except I can't find what
> pkmap or kmap stands for. I'm guessing kmap means Kernel Map but pkmap
> could be anything. current guesses are
> 
> Permanent Kernel Map
> Page Kernel Map
> PK Means Anything Pleasing
> 
> Extensive google and mailing list searching showed up nothing :-( . Any
> help or plausible suggestions are welcome

I think it's "persistant kernel map". You can't hold the atomic version
over a schedule (unless you catch faults & patch it up).

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

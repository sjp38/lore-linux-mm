Date: Sat, 6 Nov 2004 13:53:17 +0100
From: Andries Brouwer <aebr@win.tue.nl>
Subject: Re: [PATCH] Remove OOM killer ...
Message-ID: <20041106125317.GB9144@pclin040.win.tue.nl>
References: <20041105200118.GA20321@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041105200118.GA20321@logos.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Andrew Morton <akpm@osdl.org>, Nick Piggin <piggin@cyberone.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Nov 05, 2004 at 06:01:18PM -0200, Marcelo Tosatti wrote:

> My wife is almost killing me, its Friday night and I've been telling her
> "just another minute" for hours. Have to run.

:-)

> As you know the OOM is very problematic in 2.6 right now - so I went
> to investigate it.

I have always been surprised that so few people investigated
doing things right, that is, entirely without OOM killer.
Apparently developers do not think about using Linux for serious work
where it can be a disaster, possibly even a life-threatening disaster,
when any process can be killed at any time.

Ten years ago it was a bad waste of resources to have swapspace
lying around that would be used essentially 0% of the time.
But with todays disk sizes it is entirely feasible to have
a few hundred MB of "unused" swap space. A small price to
pay for the guarantee that no process will be OOM killed.

A month ago I showed a patch that made overcommit mode 2
work for me. Google finds it in http://lwn.net/Articles/104959/

So far, nobody commented.

This is not in a state such that I would like to submit it,
but I think it would be good to focus some energy into
offering a Linux that is guaranteed free of OOM surprises.

So, let me repeat the RFC.
Apply the above patch, and do "echo 2 > /proc/sys/vm/overcommit_memory".
Now test. In case you have no, or only a small amount of swap space,
also do "echo 80 > /proc/sys/vm/overcommit_ratio" or so.

Andries
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

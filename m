Date: Wed, 13 Oct 2004 00:02:06 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Page cache write performance issue
Message-Id: <20041013000206.680132ad.akpm@osdl.org>
In-Reply-To: <20041013063955.GA2079@frodo>
References: <20041013054452.GB1618@frodo>
	<20041012231945.2aff9a00.akpm@osdl.org>
	<20041013063955.GA2079@frodo>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nathan Scott <nathans@sgi.com>
Cc: piggin@cyberone.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

Nathan Scott <nathans@sgi.com> wrote:
>
> Hi Andrew,
> 
> On Tue, Oct 12, 2004 at 11:19:45PM -0700, Andrew Morton wrote:
> > Nathan Scott <nathans@sgi.com> wrote:
> > >
> > >  So, any ideas what happened to 2.6.9?
> > 
> > Does reverting the below fix it up?
> 
> Reverting that one improves things slightly - I move up from
> ~4MB/sec to ~17MB/sec; thats just under a third of the 2.6.8
> numbers I was seeing though, unfortunately.
> 

Well something else if fishy: how can you possibly achieve only 4MB/sec? 
Using floppy disks or something?

Does the same happen on ext2?

It's exactly a 500MB write on a 1000MB machine, yes?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Subject: Re: [proc.txt] Fix /proc/pid/statm documentation
From: Albert Cahalan <albert@users.sf.net>
In-Reply-To: <20040806154834.GL17188@holomorphy.com>
References: <1091754711.1231.2388.camel@cube>
	 <20040806094037.GB11358@k3.hellgate.ch> <1091797122.1231.2452.camel@cube>
	 <20040806154834.GL17188@holomorphy.com>
Content-Type: text/plain
Message-Id: <1091801683.1231.2467.camel@cube>
Mime-Version: 1.0
Date: 06 Aug 2004 10:14:43 -0400
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Roger Luethi <rl@hellgate.ch>, linux-kernel mailing list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2004-08-06 at 11:48, William Lee Irwin III wrote:
> On Fri, 2004-08-06 at 05:40, Roger Luethi wrote:
> >> And then there is the trade-off between human readable and
> >> easy to parse. ISTR there have been occasional discussions, but maybe
> >> it's time to revisit the issue because the current mess is a problem.
> 
> On Fri, Aug 06, 2004 at 08:58:43AM -0400, Albert Cahalan wrote:
> > The current bugs are a problem.
> > Quoting your other email now:
> 
> Could you describe those in isolation from other issues?

Whatever Roger found, plus:

1. trs == text RESIDENT size

2. drs == data RESIDENT size

3. memory-mapped devices should be counted for only 1 file
   (use an old Linux box running X to see)

I'm not terribly concerned right now. I just don't think
it's OK to go ripping out statm over a few bugs.

If we ripped out every buggy piece of kernel code, we'd
have a 0-byte kernel.

There are far bigger issues elsewhere, like %CPU.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

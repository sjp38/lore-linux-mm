Date: Fri, 6 Aug 2004 09:49:41 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [proc.txt] Fix /proc/pid/statm documentation
Message-ID: <20040806164941.GN17188@holomorphy.com>
References: <1091754711.1231.2388.camel@cube> <20040806094037.GB11358@k3.hellgate.ch> <1091797122.1231.2452.camel@cube> <20040806154834.GL17188@holomorphy.com> <1091801683.1231.2467.camel@cube>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1091801683.1231.2467.camel@cube>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Albert Cahalan <albert@users.sf.net>
Cc: Roger Luethi <rl@hellgate.ch>, linux-kernel mailing list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2004-08-06 at 11:48, William Lee Irwin III wrote:
>> Could you describe those in isolation from other issues?

On Fri, Aug 06, 2004 at 10:14:43AM -0400, Albert Cahalan wrote:
> Whatever Roger found, plus:
> 1. trs == text RESIDENT size
> 2. drs == data RESIDENT size
> 3. memory-mapped devices should be counted for only 1 file
>    (use an old Linux box running X to see)
> I'm not terribly concerned right now. I just don't think
> it's OK to go ripping out statm over a few bugs.
> If we ripped out every buggy piece of kernel code, we'd
> have a 0-byte kernel.
> There are far bigger issues elsewhere, like %CPU.

Okay, can you give precise definitions of trs and drs?


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

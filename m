Date: Fri, 6 Aug 2004 14:01:23 +0200
From: Roger Luethi <rl@hellgate.ch>
Subject: Re: [proc.txt] Fix /proc/pid/statm documentation
Message-ID: <20040806120123.GA23081@k3.hellgate.ch>
References: <1091754711.1231.2388.camel@cube> <20040806094037.GB11358@k3.hellgate.ch> <20040806104630.GA17188@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040806104630.GA17188@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, Albert Cahalan <albert@users.sf.net>, linux-kernel mailing list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[ fixed linux-mm address ]

On Fri, 06 Aug 2004 03:46:30 -0700, William Lee Irwin III wrote:
> On Fri, Aug 06, 2004 at 11:40:37AM +0200, Roger Luethi wrote:
> > I discussed this very issue with wli on linux-mm about a year ago. proc
> > file and documentation are still broken. So what's wrong with doing
> > something about it?
> 
> So now what, you want me to do yet another forward port of
> linux-2.4.9-statm-B1.diff?

Your call, obviously -- do you think it's worthwhile? I didn't CC you
on my initial posting because I wanted to avoid the impression that I am
trying to make this your problem somehow. Priorities as I see them are:

- Document statm content somewhere. I posted a patch to document
  the current state. It could be complemented with a description of
  what it is supposed to do.

- Come to some agreement on what the proper values should be and
  change kernels accordingly. I'm inclined to favor keeping the first two
  (albeit redundant) fields and setting the rest to 0, simply because for
  them too many different de-facto semantics live in exisiting kernels.

  A year ago, the first field was broken in 2.4 as well (not sure if/when
  it got fixed), but I can see why it is useful to keep around until top
  has found a better source. Same for the second field, the only one that
  has always been correct AFAIK.

- Provide additional information in proc files other than statm.

  The problems with undocumented records are evident, but
  /proc/pid/status may be getting too heavy for frequent parsing. It's
  not realistic to redesign proc at this point, but it would be nice
  to have some documented understanding about the direction of proc
  evolution.

Roger
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

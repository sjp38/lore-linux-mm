Date: Fri, 6 Aug 2004 17:02:36 +0200
From: Roger Luethi <rl@hellgate.ch>
Subject: Re: [proc.txt] Fix /proc/pid/statm documentation
Message-ID: <20040806150236.GA28743@k3.hellgate.ch>
References: <1091754711.1231.2388.camel@cube> <20040806094037.GB11358@k3.hellgate.ch> <20040806104630.GA17188@holomorphy.com> <20040806120123.GA23081@k3.hellgate.ch> <20040806121118.GE17188@holomorphy.com> <20040806135756.GA21411@k3.hellgate.ch> <20040806140714.GG17188@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040806140714.GG17188@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, Albert Cahalan <albert@users.sf.net>, linux-kernel mailing list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 06 Aug 2004 07:07:14 -0700, William Lee Irwin III wrote:
> On Fri, 06 Aug 2004 05:11:18 -0700, William Lee Irwin III wrote:
> >> Some of the 2.4 semantics just don't make sense. I would not find it
> >> difficult to explain what I believe correct semantics to be in a written
> >> document.
> 
> On Fri, Aug 06, 2004 at 03:57:56PM +0200, Roger Luethi wrote:
> > IMO this is a must for such files (and be it only some comments above
> > the code implementing them). I'm afraid that statm is carrying too much
> > historical baggage, though -- you would add yet another interpretation
> > of those 7 fields.
> > Tools reading statm would have to be updated anyway, so I'd rather
> > think about what could be done with a new (or just different) file.
> 
> Okay, could you write up a "specification" for what you want reported,
> then I can cook up a new file or some such for you?

Thanks for your offer. I really suck at communicating, it seems. I don't
mind implementing my suggestion or writing documentation if there is a
general agreement that this is the way to go. Currently, I am looking
for suggestions and comments.

My suggestion for /proc/pid/statm would be

Field 0 := /proc/pid/status:VmSize
Field 1 := /proc/pid/status:VmRSS
Fields 2-6: 0

That's really just cleaning up cruft and is trivial to implement.

============ Warning. Switching subject.
Maybe I should have started a separate thread for that. Sorry about
the confusion.

I am also interested in a related problem -- finding a better way for
tools to access process information. Preferably a generic way so we
don't need to keep tools and kernel in sync forever. I have some ideas,
but I don't know if they are acceptable as solutions (and if the problem
actually exists as I see it).

Most of the current problems with proc are related to tools: They don't
like changes and some of them are very sensitive to resource usage
(because they may make hundreds of calls per second on typical systems).

If we want to facilitate the use of additional information in tools,
I see two possible strategies:

- Design a new solution that enables tools to discover the fields
  that are available and to ask for a subset (as I sketched out in my
  previous post). This would remove the need for inflexible solutions
  like statm.

- Split proc information by new criteria: Slow, expensive items should
  not be in the same file as information that tools typically
  and frequently read. For instance, you could have status_basic,
  status_exotic, and status_slow. Even status_basic could have a format
  similar to /proc/pid/status, but would be shorter and contain only
  the most frequently used values (like statm today -- with all the
  problems that come with such a pre-made selection).

Roger
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

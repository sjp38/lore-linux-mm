Subject: Re: [PATCH/RFC 0/5] Memory Policy Cleanups and Enhancements
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1189537928.32731.102.camel@localhost>
References: <20070830185053.22619.96398.sendpatchset@localhost>
	 <1189527657.5036.35.camel@localhost> <1189537928.32731.102.camel@localhost>
Content-Type: text/plain
Date: Tue, 11 Sep 2007 14:45:58 -0400
Message-Id: <1189536358.5036.80.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, ak@suse.de, mtk-manpages@gmx.net, clameter@sgi.com, solo@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Tue, 2007-09-11 at 20:12 +0100, Mel Gorman wrote:
> On Tue, 2007-09-11 at 12:20 -0400, Lee Schermerhorn wrote:
> > Andi, Christoph, Mel [added to cc]:
> > 
> > Any comments on these patches, posted 30aug?  I've rebased to
> > 23-rc4-mm1, but before reposting, I wanted to give you a chance to
> > comment.
> > 
> 
> I hadn't intended to comment but because you asked, I took a look
> through. It wasn't an in-depth review but nothing jumped out as broken
> to me and I commented on what I spotted. The last patch to me was the
> most interesting and justifies the set unless someone can think of a
> real reason to not extend the get_mempolicy() API to retrieve this
> information. I made comments on what I saw but as I'm not a frequent
> user of policies so take the suggestions with a grain of salt.
> 
> Unless something jumps out to someone else, I think it'll be ready for
> wider testing after your next release.
> 
> > I'm going to add Mel's "one zonelist" series to my mempolicy tree with
> > these patches and see how that goes.  I'll slide Mel's patches in below
> > these, as it looks like they're closer to acceptance into -mm.
> > 

Thanks, again, Mel.  As I mentioned in today's "ping", I'm going to try
to merge this with your patches and wanted to give you a heads up.  The
patches will collide--in code, as well as comments, I think.

Later,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

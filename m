Date: Tue, 22 Apr 2008 23:02:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Suspect use of "first_zones_zonelist()"
Message-Id: <20080422230207.919395d7.akpm@linux-foundation.org>
In-Reply-To: <1208889639.5534.105.camel@localhost>
References: <1208877444.5534.34.camel@localhost>
	<20080422161524.GA27624@csn.ul.ie>
	<1208884215.5534.57.camel@localhost>
	<20080422174901.GA7261@csn.ul.ie>
	<1208887271.5534.99.camel@localhost>
	<1208889639.5534.105.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: mel@csn.ul.ie, linux-mm@kvack.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

> On Tue, 22 Apr 2008 14:40:39 -0400 Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> On Tue, 2008-04-22 at 14:01 -0400, Lee Schermerhorn wrote:
> > On Tue, 2008-04-22 at 18:49 +0100, Mel Gorman wrote:
> > > On (22/04/08 13:10), Lee Schermerhorn didst pronounce:
> <snip>
> 
> Andrew:  I should have mentioned that this patch is a fix to:
> 
> mm-filter-based-on-a-nodemask-as-well-as-a-gfp_mask-deporkify.patch
> 
> currently in the 25-mm1 tree.

Noted, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Mon, 6 Aug 2007 22:55:41 +0100
Subject: Re: [PATCH] Apply memory policies to top two highest zones when highest zone is ZONE_MOVABLE
Message-ID: <20070806215541.GC6142@skynet.ie>
References: <20070802172118.GD23133@skynet.ie> <200708040002.18167.ak@suse.de> <20070806121558.e1977ba5.akpm@linux-foundation.org> <200708062231.49247.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <200708062231.49247.ak@suse.de>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Lee.Schermerhorn@hp.com, clameter@sgi.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On (06/08/07 22:31), Andi Kleen didst pronounce:
> 
> > If correct, I would suggest merging the horrible hack for .23 then taking
> > it out when we merge "grouping pages by mobility".  But what if we don't do
> > that merge?
> 
> Or disable ZONE_MOVABLE until it is usable?

It's usable now. The issue with policies only occurs if the user specifies
kernelcore= or movablecore= on the command-line. Your language suggests
that you believe policies are not applied when ZONE_MOVABLE is configured
at build-time.

> I don't think we have the
> infrastructure to really use it anyways, so it shouldn't make too much difference
> in terms of features. And it's not that there is some sort of deadline
> around for it. 
> 
> Or mark it CONFIG_EXPERIMENTAL with a warning that it'll break NUMA. But disabling 
> is probably better.
> 

Saying it breaks NUMA is a excessively strong language. It doesn't break
policies in that they still get applied to the highest zone. If kernelcore=
or movablecore= is not specified, the behaviour doesn't change.

> Then for .24 or .25 a better solution can be developed.
> 

The better solution in my mind is to always filter the zonelist instead
of applying them only for MPOL_BIND zonelists as the hack does.

> I would prefer that instead of merging bandaid horrible hacks -- they have
> a tendency to stay around.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

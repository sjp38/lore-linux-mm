From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Apply memory policies to top two highest zones when highest zone is ZONE_MOVABLE
Date: Mon, 6 Aug 2007 22:31:49 +0200
References: <20070802172118.GD23133@skynet.ie> <200708040002.18167.ak@suse.de> <20070806121558.e1977ba5.akpm@linux-foundation.org>
In-Reply-To: <20070806121558.e1977ba5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200708062231.49247.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@skynet.ie>, Lee.Schermerhorn@hp.com, clameter@sgi.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> If correct, I would suggest merging the horrible hack for .23 then taking
> it out when we merge "grouping pages by mobility".  But what if we don't do
> that merge?

Or disable ZONE_MOVABLE until it is usable? I don't think we have the
infrastructure to really use it anyways, so it shouldn't make too much difference
in terms of features. And it's not that there is some sort of deadline
around for it. 

Or mark it CONFIG_EXPERIMENTAL with a warning that it'll break NUMA. But disabling 
is probably better.

Then for .24 or .25 a better solution can be developed.

I would prefer that instead of merging bandaid horrible hacks -- they have
a tendency to stay around.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Mon, 6 Aug 2007 12:18:13 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Apply memory policies to top two highest zones when
 highest zone is ZONE_MOVABLE
In-Reply-To: <20070806121558.e1977ba5.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0708061216570.7603@schroedinger.engr.sgi.com>
References: <20070802172118.GD23133@skynet.ie> <200708040002.18167.ak@suse.de>
 <20070806121558.e1977ba5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <ak@suse.de>, Mel Gorman <mel@skynet.ie>, Lee.Schermerhorn@hp.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 6 Aug 2007, Andrew Morton wrote:

> If correct, I would suggest merging the horrible hack for .23 then taking
> it out when we merge "grouping pages by mobility".  But what if we don't do
> that merge?

Take the horrible hack for .23.

For .24 either merge the mobility or get the other solution that Mel is 
working on. That solution would only use a single zonelist per node and 
filter on the fly. That may help performance and also help to make memory 
policies work better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Wed, 12 Sep 2007 10:06:49 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 4/6] Embed zone_id information within the zonelist->zones
 pointer
In-Reply-To: <20070912165138.5deb4db4.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0709121005090.1144@schroedinger.engr.sgi.com>
References: <20070911213006.23507.19569.sendpatchset@skynet.skynet.ie>
 <20070911213127.23507.34058.sendpatchset@skynet.skynet.ie>
 <20070912165138.5deb4db4.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Lee.Schermerhorn@hp.com, akpm@linux-foundation.org, ak@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 12 Sep 2007, KAMEZAWA Hiroyuki wrote:

> If we really want to avoid unnecessary access to "zone" while walking zonelist,
> above may do something good.  Cons is this makes sizeof zonlist bigger.

The trouble is that the size of the zonelist would double with this 
approach. We have long zonelists and doubling the size could double 
the cachelines needed to be touched in order to scan the zonelists.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

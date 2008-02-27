Date: Wed, 27 Feb 2008 14:00:48 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 3/6] Remember what the preferred zone is for zone_statistics
In-Reply-To: <20080227214728.6858.79000.sendpatchset@localhost>
Message-ID: <Pine.LNX.4.64.0802271400110.12963@schroedinger.engr.sgi.com>
References: <20080227214708.6858.53458.sendpatchset@localhost>
 <20080227214728.6858.79000.sendpatchset@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: akpm@linux-foundation.org, mel@csn.ul.ie, ak@suse.de, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, rientjes@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

> This patch records what the preferred zone is rather than assuming the
> first zone in the zonelist is it. This simplifies the reading of later
> patches in this set.

And is needed for correctness if GFP_THISNODE is used?

Reviewed-by: Christoph Lameter <clameter@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

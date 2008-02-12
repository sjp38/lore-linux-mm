Date: Mon, 11 Feb 2008 21:06:47 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH for 2.6.24][regression fix] Mempolicy: silently restrict
 nodemask to allowed nodes V3
In-Reply-To: <20080212122637.29B7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.00.0802112104510.21310@chino.kir.corp.google.com>
References: <alpine.LFD.1.00.0802092340400.2896@woody.linux-foundation.org> <1202748459.5014.50.camel@localhost> <20080212122637.29B7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, Christoph Lameter <clameter@sgi.com>, Paul Jackson <pj@sgi.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Feb 2008, KOSAKI Motohiro wrote:

> [PATCH] 2.6.24 - mempolicy:  silently restrict nodemask to allowed nodes
> 

Linus has already merged this patch into his tree, but next time you 
pass along a contribution to a maintainer the first line should read:

From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>

so the person who actually wrote the patch is listed as the author in the 
git commit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

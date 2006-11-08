Date: Tue, 7 Nov 2006 18:01:11 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Fix sys_move_pages when a NULL node list is passed.
In-Reply-To: <20061108105648.4a149cca.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0611071800250.7749@schroedinger.engr.sgi.com>
References: <20061103144243.4601ba76.sfr@canb.auug.org.au>
 <20061108105648.4a149cca.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 Nov 2006, KAMEZAWA Hiroyuki wrote:

> >  	pm[nr_pages].node = MAX_NUMNODES;
> 
> I think node0 is always online...but this should be
> 
> pm[i].node = first_online_node; // /* any online node */

No it is a marker. The use of any node that is online could lead to a 
false determination of the endpoint of the list.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

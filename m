Date: Wed, 8 Nov 2006 11:13:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Fix sys_move_pages when a NULL node list is passed.
Message-Id: <20061108111341.748d034a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0611071800250.7749@schroedinger.engr.sgi.com>
References: <20061103144243.4601ba76.sfr@canb.auug.org.au>
	<20061108105648.4a149cca.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0611071800250.7749@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: sfr@canb.auug.org.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Tue, 7 Nov 2006 18:01:11 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Wed, 8 Nov 2006, KAMEZAWA Hiroyuki wrote:
> 
> > >  	pm[nr_pages].node = MAX_NUMNODES;
> > 
> > I think node0 is always online...but this should be
> > 
> > pm[i].node = first_online_node; // /* any online node */
> 
> No it is a marker. The use of any node that is online could lead to a 
> false determination of the endpoint of the list.
> 
Ah.. I'm mentioning to this.
==
+			pm[i].node = 0;	/* anything to not match MAX_NUMNODES */
==
Sorry for my bad cut & paste.

It seems that this 0 will be passed to alloc_pages_node().
alloc_pages_node() doesn't check whether a node is online or not before using 
NODE_DATA().

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

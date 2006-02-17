Date: Fri, 17 Feb 2006 08:05:50 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH for 2.6.16] Handle holes in node mask in node fallback
 list initialization
In-Reply-To: <20060217145409.4064.Y-GOTO@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0602170805120.30999@schroedinger.engr.sgi.com>
References: <200602170223.34031.ak@suse.de> <Pine.LNX.4.64.0602161749330.27091@schroedinger.engr.sgi.com>
 <20060217145409.4064.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Andi Kleen <ak@suse.de>, torvalds@osdl.org, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 17 Feb 2006, Yasunori Goto wrote:

> > These are empty nodes without processor? Or a processor without a node?
> > In that case the processor will have to be assigned a default node.
> 
> ??? 
> Ia64 added the feature of memory less node long time ago.

Correct but a processor without a node is a new configuration. The 
processor has to be assigned some node.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

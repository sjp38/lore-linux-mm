Date: Thu, 8 May 2003 16:52:18 +0200
From: Andi Kleen <ak@muc.de>
Subject: Re: Redundant zonelist initialization
Message-ID: <20030508145218.GA4355@averell>
References: <20030508112339.GA7394@averell> <24990000.1052396565@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <24990000.1052396565@[10.10.2.4]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Andi Kleen <ak@muc.de>, linux-mm@kvack.org, akpm@digeo.com
List-ID: <linux-mm.kvack.org>

On Thu, May 08, 2003 at 02:22:47PM +0200, Martin J. Bligh wrote:
> 
> 
> --On Thursday, May 08, 2003 13:23:39 +0200 Andi Kleen <ak@muc.de> wrote:
> 
> > When booting 2.5.69 on a 4 Node CONFIG_DISCONTIGMEM machine I get:
> > 
> > Building zonelist for node : 0
> > Building zonelist for node : 1
> > Building zonelist for node : 2
> > Building zonelist for node : 3
> > Building zonelist for node : 0
> > Building zonelist for node : 0
> > Building zonelist for node : 0
> > Building zonelist for node : 0
> > 
> > Why does it initialize the zonelist for node 0 five times?
> 
> Looks like you have numnodes wrong ...
> 
> void __init build_all_zonelists(void)
> {
>         int i;
> 
>         for(i = 0 ; i < numnodes ; i++)
>                 build_zonelists(NODE_DATA(i));
> }

Only with new mathematics :-) How can any value for numnodes explain 
such a sequence ? 

I think it actually comes from the two loops calling build_zonelist_node 
in build_zonelists(). But I'm not sure why it produces such a strange sequence.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

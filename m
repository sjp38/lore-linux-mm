Date: Thu, 08 May 2003 05:22:47 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: Redundant zonelist initialization
Message-ID: <24990000.1052396565@[10.10.2.4]>
In-Reply-To: <20030508112339.GA7394@averell>
References: <20030508112339.GA7394@averell>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@muc.de>, linux-mm@kvack.org
Cc: akpm@digeo.com
List-ID: <linux-mm.kvack.org>


--On Thursday, May 08, 2003 13:23:39 +0200 Andi Kleen <ak@muc.de> wrote:

> When booting 2.5.69 on a 4 Node CONFIG_DISCONTIGMEM machine I get:
> 
> Building zonelist for node : 0
> Building zonelist for node : 1
> Building zonelist for node : 2
> Building zonelist for node : 3
> Building zonelist for node : 0
> Building zonelist for node : 0
> Building zonelist for node : 0
> Building zonelist for node : 0
> 
> Why does it initialize the zonelist for node 0 five times?

Looks like you have numnodes wrong ...

void __init build_all_zonelists(void)
{
        int i;

        for(i = 0 ; i < numnodes ; i++)
                build_zonelists(NODE_DATA(i));
}



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

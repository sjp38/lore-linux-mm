Message-ID: <42199049.2090408@sgi.com>
Date: Mon, 21 Feb 2005 01:39:53 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: [RFC 2.6.11-rc2-mm2 0/7] mm: manual page migration -- overview
 II
References: <20050215121404.GB25815@muc.de>	<421241A2.8040407@sgi.com>	<20050215214831.GC7345@wotan.suse.de>	<4212C1A9.1050903@sgi.com>	<20050217235437.GA31591@wotan.suse.de>	<4215A992.80400@sgi.com>	<20050218130232.GB13953@wotan.suse.de>	<42168FF0.30700@sgi.com>	<20050220214922.GA14486@wotan.suse.de>	<20050220143023.3d64252b.pj@sgi.com>	<20050220223510.GB14486@wotan.suse.de> <20050220175019.0e588466.pj@sgi.com>
In-Reply-To: <20050220175019.0e588466.pj@sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Andi Kleen <ak@suse.de>, ak@muc.de, raybry@austin.rr.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Paul Jackson wrote:
>>
>>You have to walk to full node mapping for each array, but
>>even with hundreds of nodes that should not be that costly
> 
> 
> I presume if you knew that the job only had pages on certain nodes,
> perhaps due to aggressive use of cpusets, that you would only have to
> walk those nodes, right?
> 
I don't think Andi was proposing you have to search all of the pages
on a node.  I think that the idea was that the (count, old_nodes, new_nodes)
parameters would have to be converted to a full node_map such as is done
in the patch (let's call it "sample code") that I sent out with the
overview that started this whole discussion.  node_map[] is MAX_NUMNODES
in length, and node_map[i] gives the node where pages on node i should be
migrated to, or is -1 if we are not migrating pages on this node.

Since we have extended the interface to support -1 as a possible value for
the old_nodes array [and it matches any old node], then in that case we
would make node_map[i]=new_node for all values of i.

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

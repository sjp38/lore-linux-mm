Date: Fri, 15 Sep 2006 10:13:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Get rid of zone_table
In-Reply-To: <450AAA83.3040905@shadowen.org>
Message-ID: <Pine.LNX.4.64.0609151010520.7975@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609131340050.19059@schroedinger.engr.sgi.com>
 <1158180795.9141.158.camel@localhost.localdomain>
 <Pine.LNX.4.64.0609131425010.19380@schroedinger.engr.sgi.com>
 <1158184047.9141.164.camel@localhost.localdomain> <450AAA83.3040905@shadowen.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 15 Sep 2006, Andy Whitcroft wrote:

> The flags field only has a 9 bit space for these value fields.  Into
> which we normally shove NODE,ZONE.  With SPARSEMEM that is SECTION,ZONE
> and so there is only room for 6-7 bits of information in this field.
> 
> The section table only contains an adjusted pointer to the mem_map for
> that section?  We use the bottom two bits of that pointer for a couple
> of flags.  I don't think there is any space in it.

Great! If we only have 6-7 bits that means a max of 128 sections, right? 
And you have always less than 256 nodes? How about making the 
section_to_nid array a byte vector? It will then fit into one cacheline 
and be only little less hot than NODE_DATA() so we should be even faster 
than before. The zone_table is currently certainly much larger than a 
single cacheline.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Wed, 13 Sep 2006 14:54:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Get rid of zone_table
In-Reply-To: <1158184047.9141.164.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0609131452330.19506@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609131340050.19059@schroedinger.engr.sgi.com>
 <1158180795.9141.158.camel@localhost.localdomain>
 <Pine.LNX.4.64.0609131425010.19380@schroedinger.engr.sgi.com>
 <1158184047.9141.164.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 13 Sep 2006, Dave Hansen wrote:

> Now that I think about it, we should have room to encode that thing
> inside of the section number on 32-bit platforms.

We already have 1k nodes on IA64 and you can expect 16k in the 
near future. I think you need at least 16 bit.

Sorry I am a bit new to sparsemem but it seems that the mem sections are 
arrays of pointers. You would like to store the node number in the lower 
unused bits?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

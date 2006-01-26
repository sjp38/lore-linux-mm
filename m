Date: Thu, 26 Jan 2006 09:54:47 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [patch 3/9] mempool - Make mempools NUMA aware
In-Reply-To: <1138233093.27293.1.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.62.0601260953200.15128@schroedinger.engr.sgi.com>
References: <20060125161321.647368000@localhost.localdomain>
 <1138233093.27293.1.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, sri@us.ibm.com, andrea@suse.de, pavel@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 25 Jan 2006, Matthew Dobson wrote:

> plain text document attachment (critical_mempools)
> Add NUMA-awareness to the mempool code.  This involves several changes:

I am not quite sure why you would need numa awareness in an emergency 
memory pool. Presumably the effectiveness of the accesses do not matter. 
You only want to be sure that there is some memory available right?

You do not need this.... 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Message-ID: <43D96AEC.4030200@us.ibm.com>
Date: Thu, 26 Jan 2006 16:35:56 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [patch 3/9] mempool - Make mempools NUMA aware
References: <20060125161321.647368000@localhost.localdomain> <1138233093.27293.1.camel@localhost.localdomain> <20060127002331.GH10409@kvack.org>
In-Reply-To: <20060127002331.GH10409@kvack.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: linux-kernel@vger.kernel.org, sri@us.ibm.com, andrea@suse.de, pavel@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Benjamin LaHaise wrote:
> On Wed, Jan 25, 2006 at 03:51:33PM -0800, Matthew Dobson wrote:
> 
>>plain text document attachment (critical_mempools)
>>Add NUMA-awareness to the mempool code.  This involves several changes:
> 
> 
> This is horribly bloated.  Mempools should really just be a flag and 
> reserve count on a slab, as then the code would not be in hot paths.
> 
> 		-ben

Ummm...  ok?  But with only a simple flag, how do you know *which* mempool
you're trying to use?  What if you want to use a mempool for a non-slab
allocation?

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

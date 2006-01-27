Date: Thu, 26 Jan 2006 19:23:31 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [patch 3/9] mempool - Make mempools NUMA aware
Message-ID: <20060127002331.GH10409@kvack.org>
References: <20060125161321.647368000@localhost.localdomain> <1138233093.27293.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1138233093.27293.1.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, sri@us.ibm.com, andrea@suse.de, pavel@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 25, 2006 at 03:51:33PM -0800, Matthew Dobson wrote:
> plain text document attachment (critical_mempools)
> Add NUMA-awareness to the mempool code.  This involves several changes:

This is horribly bloated.  Mempools should really just be a flag and 
reserve count on a slab, as then the code would not be in hot paths.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

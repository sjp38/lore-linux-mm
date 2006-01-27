Date: Thu, 26 Jan 2006 22:23:10 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [patch 3/9] mempool - Make mempools NUMA aware
Message-ID: <20060127032307.GI10409@kvack.org>
References: <20060125161321.647368000@localhost.localdomain> <1138233093.27293.1.camel@localhost.localdomain> <20060127002331.GH10409@kvack.org> <43D96AEC.4030200@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <43D96AEC.4030200@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, sri@us.ibm.com, andrea@suse.de, pavel@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 26, 2006 at 04:35:56PM -0800, Matthew Dobson wrote:
> Ummm...  ok?  But with only a simple flag, how do you know *which* mempool
> you're trying to use?  What if you want to use a mempool for a non-slab
> allocation?

Are there any?  A quick poke around has only found a couple of places 
that use kzalloc(), which is still quite effectively a slab allocation.  
There seems to be just one page user, the dm-crypt driver, which could 
be served by a reservation scheme.

		-ben
-- 
"Ladies and gentlemen, I'm sorry to interrupt, but the police are here 
and they've asked us to stop the party."  Don't Email: <dont@kvack.org>.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

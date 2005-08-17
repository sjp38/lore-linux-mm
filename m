Date: Wed, 17 Aug 2005 23:04:32 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 0/4] Demand faunting for huge pages
Message-ID: <20050817210431.GR3996@wotan.suse.de>
References: <1124304966.3139.37.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1124304966.3139.37.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, christoph@lameter.com, ak@suse.de, kenneth.w.chen@intel.com, david@gibson.dropbear.id.au
List-ID: <linux-mm.kvack.org>

What about the overcommit issue Ken noted? It needs to be solved
in some way at least, either with the full check or the lazy simple
check.

Also I still think your get_user_pages approach is questionable.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

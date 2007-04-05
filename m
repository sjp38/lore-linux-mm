Date: Thu, 05 Apr 2007 16:10:27 -0700 (PDT)
Message-Id: <20070405.161027.115909479.davem@davemloft.net>
Subject: Re: [PATCH 4/4] IA64: SPARSE_VIRTUAL 16M page size support
From: David Miller <davem@davemloft.net>
In-Reply-To: <617E1C2C70743745A92448908E030B2A0153594A@scsmsx411.amr.corp.intel.com>
References: <20070404230635.20292.81141.sendpatchset@schroedinger.engr.sgi.com>
	<617E1C2C70743745A92448908E030B2A0153594A@scsmsx411.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 5 Apr 2007 15:50:02 -0700
Return-Path: <owner-linux-mm@kvack.org>
To: tony.luck@intel.com
Cc: clameter@sgi.com, akpm@linux-foundation.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, mbligh@google.com, linux-mm@kvack.org, ak@suse.de, hansendc@us.ibm.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

> Maybe a granule is not the right unit of allocation ... perhaps 4M
> would work better (4M/56 ~= 75000 pages ~= 1.1G)?  But if this is
> too small, then a hard-coded 16M would be better than a granule,
> because 64M is (IMHO) too big.

A 4MB chunk of page structs covers about 512MB of ram (I'm rounding up
to 64-bytes in my calculations and using an 8K page size, sorry :-).
So I think that is too small although on the sparc64 side that is the
biggest I have available on most processor models.

But I do agree that 64MB is way too big and 16MB is a good compromise
chunk size for this stuff.  That covers about 2GB of ram with the
above parameters, which should be about right.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

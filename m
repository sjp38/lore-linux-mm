Date: Thu, 01 Aug 2002 18:19:44 -0700 (PDT)
Message-Id: <20020801.181944.09310618.davem@redhat.com>
Subject: Re: large page patch
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <3D49DFD0.FE0DBC1D@zip.com.au>
References: <3D49D45A.D68CCFB4@zip.com.au>
	<20020801.174301.123634127.davem@redhat.com>
	<3D49DFD0.FE0DBC1D@zip.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@zip.com.au
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rohit.seth@intel.com, sunil.saxena@intel.com, asit.k.mallick@intel.com
List-ID: <linux-mm.kvack.org>

   "David S. Miller" wrote:
   > This is probably done to increase the likelyhood that 4MB page orders
   > are available.  If we collapse 4MB pages deeper, they are less likely
   > to be broken up because smaller orders would be selected first.
   
   This is leakage from ia64, which supports up to 256k pages.

Ummm, 4MB > 256K and even with a 4K PAGE_SIZE MAX_ORDER coalesces
up to 4MB already :-)
   
   Apparently a page-table based representation could not be used by PPC.
   
The page-table is just an abstraction, there is no reason dummy
"large" ptes could not be used which are just ignored by the HW TLB
reload code.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

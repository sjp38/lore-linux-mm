Date: Thu, 01 Aug 2002 17:43:01 -0700 (PDT)
Message-Id: <20020801.174301.123634127.davem@redhat.com>
Subject: Re: large page patch
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <3D49D45A.D68CCFB4@zip.com.au>
References: <3D49D45A.D68CCFB4@zip.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@zip.com.au
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rohit.seth@intel.com, sunil.saxena@intel.com, asit.k.mallick@intel.com
List-ID: <linux-mm.kvack.org>

   Some observations which have been made thus far:
   
   - Minimal impact on the VM and MM layers
   
Well the downside of this is that it means it isn't transparent
to userspace.  For example, specfp2000 results aren't going to
improve after installing these changes.  Some of the other large
page implementations would.

   - The change to MAX_ORDER is unneeded
   
This is probably done to increase the likelyhood that 4MB page orders
are available.  If we collapse 4MB pages deeper, they are less likely
to be broken up because smaller orders would be selected first.

Maybe it doesn't make a difference....

   - swapping of large pages and making them pagecache-coherent is
     unpopular.
   
Swapping them is easy, any time you hit a large PTE you unlarge it.
This is what some of other large page implementations do.  Basically
the implementation is that set_pte() breaks apart large ptes when
necessary.

I agree on the pagecache side.

Actually to be honest the other implementations seemed less
intrusive and easier to add support for.  The downside is that
handling of weird cases like x86 using pmd's for 4MB pages
was not complete last time I checked.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

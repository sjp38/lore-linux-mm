Date: Thu, 07 Oct 2004 09:02:57 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: RE: [RFC/PATCH]  pfn_valid() more generic : arch independent part[0/2]
Message-ID: <1260420000.1097164975@[10.10.2.4]>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F022668D0@scsmsx401.amr.corp.intel.com>
References: <B8E391BBE9FE384DAA4C5C003888BE6F022668D0@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>, Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LinuxIA64 <linux-ia64@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--"Luck, Tony" <tony.luck@intel.com> wrote (on Thursday, October 07, 2004 08:53:32 -0700):

>> The normal way to fix the above is just to have a bitmap array 
>> to test - in your case a 1GB granularity would be sufficicent. That 
>> takes < 1 word to implement for the example above ;-)
> 
> In the general case you need a bit for each granule (since that is the
> unit that the kernel admits/denies the existence of memory).  But the
> really sparse systems end up with a large bitmap.  SGI Altix uses 49
> physical address bits, and a granule size of 16MB ... so we need 2^25
> bits ... i.e. 4MBbytes.  While that's a drop in the ocean on a 4TB
> machine, it still seems a pointless waste.

If it's that sparse, it might be worth having another data structure,
perhaps a tree, or some form of hierarchical bitmap. But probably the
most important thing is to do it in one cacheline read, so personally
I'd stick with the array. Whatever you chose, I still don't understand 
where all that code came from ;-)

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

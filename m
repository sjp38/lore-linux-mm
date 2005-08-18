From: "Ray Bryant" <raybry@mpdtxmail.amd.com>
Subject: Re: [PATCH 0/4] Demand faunting for huge pages
Date: Thu, 18 Aug 2005 10:29:00 -0500
References: <1124304966.3139.37.camel@localhost.localdomain>
 <20050817210431.GR3996@wotan.suse.de>
 <20050818003302.GE7103@localhost.localdomain>
In-Reply-To: <20050818003302.GE7103@localhost.localdomain>
MIME-Version: 1.0
Message-ID: <200508181029.01238.raybry@mpdtxmail.amd.com>
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Gibson <david@gibson.dropbear.id.au>
Cc: Andi Kleen <ak@suse.de>, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org, christoph@lameter.com, kenneth.w.chen@intel.com, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Wednesday 17 August 2005 19:33, David Gibson wrote:

>
> Strict accounting leads to nicer behaviour in some cases - you'll tend
> to die early rather than late - but it seems an awful lot of work for
> a fairly small improvement in behaviour.
>

The last time we went around on this (April 2004?) Andrew thought that adding 
demand allocation for hugetlb pages without strict accounting was effectively 
an ABI change -- in the current approach the mmap() will fail if you ask for 
too many hugetlb pages whilst in the demand fault approach you will get 
SIGBUS at a later point in time.   At one time this was considered serious 
enough to fix.

Andy Whitcroft provided some code for the patch that Ken and I did back in
April 2004 time frame.   I can't find that one but the following patch from
Christoph Lameter appears to be the code.  The idea is that at mmap() time
a strict reservation is made that guarantees the necessary number of 
hugetlb pages is available. 

http://marc.theaimsgroup.com/?l=linux-kernel&m=109842250714489&w=2

-- 
Ray Bryant
AMD Performance Labs                   Austin, Tx
512-602-0038 (o)                 512-507-7807 (c)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

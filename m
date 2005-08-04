Message-Id: <200508042249.j74Mndg18582@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: Getting rid of SHMMAX/SHMALL ?
Date: Thu, 4 Aug 2005 15:49:37 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <20050804132338.GT8266@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Andi Kleen' <ak@suse.de>, Hugh Dickins <hugh@veritas.com>
Cc: linux-kernel@vger.kernel.org, Anton Blanchard <anton@samba.org>, cr@sap.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote on Thursday, August 04, 2005 6:24 AM
> I think we should just get rid of the per process limit and keep
> the global limit, but make it auto tuning based on available memory.
> That is still not very nice because that would likely keep it < available 
> memory/2, but I suspect databases usually want more than that. So
> I would even make it bigger than tmpfs for reasonably big machines.
> Let's say
> 
> if (main memory >= 1GB)
> 	maxmem = main memory - main memory/8 

This might be too low on large system.  We usually stress shm pretty hard
for db application and usually use more than 87% of total memory in just
one shm segment.  So I prefer either no limit or a tunable.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Mon, 12 Jun 2006 09:43:17 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH]: Adding a counter in vma to indicate the number of
 physical pages backing it
In-Reply-To: <1149903235.31417.84.camel@galaxy.corp.google.com>
Message-ID: <Pine.LNX.4.64.0606120941500.19214@schroedinger.engr.sgi.com>
References: <1149903235.31417.84.camel@galaxy.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rohit Seth <rohitseth@google.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux-mm@kvack.org, Linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 9 Jun 2006, Rohit Seth wrote:

> There is currently /proc/<pid>/smaps that prints the detailed
> information about the usage of physical pages but that is a very
> expensive operation as it traverses all the PTs (for some one who is
> just interested in getting that data for each vma).

Adding a new counter to a vma may cause a bouncing cacheline etc. I 
would think that such a counter is far more expensive than occasional 
scans through the page table because someone is curious about the 
number of page in use. /proc/<pid>/numa_maps also uses these scans to 
determine dirty pages etc.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

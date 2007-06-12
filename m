Date: Tue, 12 Jun 2007 12:00:09 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Add populated_map to account for memoryless nodes
In-Reply-To: <1181674482.5592.98.camel@localhost>
Message-ID: <Pine.LNX.4.64.0706121159310.31158@schroedinger.engr.sgi.com>
References: <20070611202728.GD9920@us.ibm.com>
 <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com>
 <1181657433.5592.11.camel@localhost> <20070612173521.GX3798@us.ibm.com>
 <Pine.LNX.4.64.0706121138050.30754@schroedinger.engr.sgi.com>
 <1181674482.5592.98.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Jun 2007, Lee Schermerhorn wrote:

> Perhaps.  But, be aware that allocating pages via the 'hugepages' boot
> parameter or the vm.nr_hugepages sysctl won't spread pages evenly--on
> our platforms, anyway--if we don't get this right.  From what I've seen
> in the mailing lists, this approach [fixing it up with the per node
> attributes] runs counter to the general approach of having the kernel
> figure it out.  

Hmm.. shmem does the same with the boot parameter there?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

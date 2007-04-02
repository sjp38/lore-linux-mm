From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 1/4] x86_64: Switch to SPARSE_VIRTUAL
Date: Mon, 2 Apr 2007 19:14:07 +0200
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com> <200704021744.39880.ak@suse.de> <Pine.LNX.4.64.0704020851300.30394@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0704020851300.30394@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200704021914.07541.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> No no no. For the gazillions time: All of 1-1 mapped kernel memory on 
> x86_64 needs a 2 MB page table entry. The virtual memmap uses the same. 
> There are *no* additional TLBs used.

But why do you reserve an own virtual area then if you claim to not use any
additional mappings? 

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

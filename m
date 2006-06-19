Date: Mon, 19 Jun 2006 12:03:48 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH] inactive_clean
In-Reply-To: <1150740624.28517.108.camel@lappy>
Message-ID: <Pine.LNX.4.64.0606191202350.23422@schroedinger.engr.sgi.com>
References: <1150719606.28517.83.camel@lappy>
 <Pine.LNX.4.64.0606190837450.1184@schroedinger.engr.sgi.com>
 <1150740624.28517.108.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@osdl.org>, Andi Kleen <ak@suse.de>, Rohit Seth <rohitseth@google.com>, Andrew Morton <akpm@osdl.org>, mbligh@google.com, hugh@veritas.com, riel@redhat.com, andrea@suse.de, arjan@infradead.org, apw@shadowen.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, Nick Piggin <piggin@cyberone.com.au>, linux-mm <linux-mm@kvack.org>, Nikita Danilov <nikita@clusterfs.com>
List-ID: <linux-mm.kvack.org>

On Mon, 19 Jun 2006, Peter Zijlstra wrote:

> http://linux-mm.org/NetworkStorageDeadlock
> 
> Basically, we want to free memory, but freeing costs more memory than we
> currently have available.

Freeing of anonymous memory does not cost anythin when the process 
terminates. You mean free through swapping? The problem is the swap via 
the network?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Document Linux Memory Policy
Date: Thu, 31 May 2007 13:47:28 +0200
References: <1180467234.5067.52.camel@localhost> <200705311243.20119.ak@suse.de> <20070531110412.GM4715@minantech.com>
In-Reply-To: <20070531110412.GM4715@minantech.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200705311347.28214.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gleb Natapov <glebn@voltaire.com>
Cc: Christoph Lameter <clameter@sgi.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> No it is not (not always).

Natural = as in benefits a large number of application. Your requirement
seems to be quite special.

> I want to create shared memory for 
> interprocess communication. Process A will write into the memory and
> process B will periodically poll it to see if there is a message there.
> In NUMA system I want the physical memory for this VMA to be allocated
> from node close to process B 

Then bind it to the node of process B (using numa_set_membind())

-Andi 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

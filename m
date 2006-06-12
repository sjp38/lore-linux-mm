From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH]: Adding a counter in vma to indicate the number of physical pages backing it
Date: Mon, 12 Jun 2006 13:17:44 +0200
References: <1149903235.31417.84.camel@galaxy.corp.google.com> <1150042142.3131.82.camel@laptopd505.fenrus.org>
In-Reply-To: <1150042142.3131.82.camel@laptopd505.fenrus.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200606121317.44139.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: rohitseth@google.com, Andrew Morton <akpm@osdl.org>, Linux-mm@kvack.org, Linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sunday 11 June 2006 18:09, Arjan van de Ven wrote:
> On Fri, 2006-06-09 at 18:33 -0700, Rohit Seth wrote:
> > Below is a patch that adds number of physical pages that each vma is
> > using in a process.  Exporting this information to user space
> > using /proc/<pid>/maps interface.
> 
> is it really worth bloating the vma struct for this? there are quite a
> few workloads that have a gazilion vma's, and this patch adds both
> memory usage and cache pressure to those workloads...

I agree it's a bad idea. smaps is only a debugging kludge anyways
and it's not a good idea to we bloat core data structures for it.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

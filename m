Date: Mon, 24 Mar 2008 14:05:02 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: larger default page sizes...
In-Reply-To: <20080324.133722.38645342.davem@davemloft.net>
Message-ID: <Pine.LNX.4.64.0803241402060.7762@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0803211037140.18671@schroedinger.engr.sgi.com>
 <20080321.145712.198736315.davem@davemloft.net>
 <Pine.LNX.4.64.0803241121090.3002@schroedinger.engr.sgi.com>
 <20080324.133722.38645342.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 24 Mar 2008, David Miller wrote:

> From: Christoph Lameter <clameter@sgi.com>
> Date: Mon, 24 Mar 2008 11:27:06 -0700 (PDT)
> 
> > The move to 64k page size on IA64 is another way that this issue can
> > be addressed though.
> 
> This is such a huge mistake I wish platforms such as powerpc and IA64
> would not make such decisions so lightly.

Its certainly not a light decision if your customer tells you that the box 
is almost unusable with 16k page size. For our new 2k and 4k processor 
systems this seems to be a requirement. Customers start hacking SLES10 to 
run with 64k pages....

> The memory wastage is just rediculious.

Well yes if you would use such a box for kernel compiles and small files 
then its a bad move. However, if you have to process terabytes of data 
then this is significantly reducing the VM and I/O overhead.

> I already see several distributions moving to 64K pages for powerpc,
> so I want to nip this in the bud before this monkey-see-monkey-do
> thing gets any more out of hand.

powerpc also runs HPC codes. They certainly see the same results that we 
see.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

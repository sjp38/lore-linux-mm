Date: Thu, 5 Apr 2007 15:27:00 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/4] Generic Virtual Memmap suport for SPARSEMEM V3
In-Reply-To: <20070405.142900.59466568.davem@davemloft.net>
Message-ID: <Pine.LNX.4.64.0704051525350.15901@schroedinger.engr.sgi.com>
References: <20070404230619.20292.4475.sendpatchset@schroedinger.engr.sgi.com>
 <20070405.142900.59466568.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: Andy Whitcroft <apw@shadowen.org>, akpm@linux-foundation.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, mbligh@google.com, linux-mm@kvack.org, ak@suse.de, hansendc@us.ibm.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu, 5 Apr 2007, David Miller wrote:

> Hey Christoph, here is sparc64 support for this stuff.

Great!

> After implementing this and seeing more and more how it works, I
> really like it :-)
> 
> Thanks a lot for doing this work Christoph!

Thanks for the appreciation. CCing Andy Whitcroft who will hopefully 
merge this all of this together into sparsemem including the S/390 
implementation.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

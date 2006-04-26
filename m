Date: Wed, 26 Apr 2006 11:47:37 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Lockless page cache test results
Message-Id: <20060426114737.239806a2.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0604261130450.19587@schroedinger.engr.sgi.com>
References: <20060426135310.GB5083@suse.de>
	<20060426095511.0cc7a3f9.akpm@osdl.org>
	<20060426174235.GC5002@suse.de>
	<20060426111054.2b4f1736.akpm@osdl.org>
	<Pine.LNX.4.64.0604261130450.19587@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: axboe@suse.de, linux-kernel@vger.kernel.org, npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@sgi.com> wrote:
>
> On Wed, 26 Apr 2006, Andrew Morton wrote:
> 
> > OK.  That doesn't sound like something which a real application is likely
> > to do ;)
> 
> A real application scenario may be an application that has lots of threads 
> that are streaming data through multiple different disk channels (that 
> are able to transfer data simultanouesly. e.g. connected to different 
> nodes in a NUMA system) into the same address space.
> 
> Something like the above is fairly typical for multimedia filters 
> processing large amounts of data.

>From the same file?

To /dev/null?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Wed, 30 Apr 2003 23:29:17 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Memory allocation problem
Message-ID: <20030430232917.A24259@infradead.org>
References: <20030430221438.16759.qmail@webmail35.rediffmail.com> <20030430222825.GA25371@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030430222825.GA25371@kroah.com>; from greg@kroah.com on Wed, Apr 30, 2003 at 03:28:25PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Greg KH <greg@kroah.com>
Cc: anand kumar <a_santha@rediffmail.com>, linux-mm@kvack.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 30, 2003 at 03:28:25PM -0700, Greg KH wrote:
> On Wed, Apr 30, 2003 at 10:14:38PM -0000, anand kumar wrote:
> > 
> > Is there any other mechanism to allocate large amount of 
> > physically contiguous memory blocks during normal run time of the
> > driver? Is this being addressed in later kernels.
> 
> Look at vmalloc().  It should do what you are looking for.

vmalloc is not physically continguos,  He could use bootmem
unless he wants his driver to work modular.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Date: Wed, 24 May 2000 12:55:46 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Large shared memory segment in kernel
Message-ID: <20000524125546.J31803@redhat.com>
References: <v03007801b55167f9bf16@[194.5.49.5]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <v03007801b55167f9bf16@[194.5.49.5]>; from letz@grame.fr on Wed, May 24, 2000 at 01:14:40PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephane Letz <letz@grame.fr>
Cc: linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, May 24, 2000 at 01:14:40PM +0200, Stephane Letz wrote:

> We would like to allocate a large memory segment (several Mb) in a kernel
> module so that to access the memory in the kernel module and in user space
> application. (be implementing the mmap function in the kernel module)
> Is is something that could be done ?  Or kernel modules should only mmap
> small amount of memory?

As long as you are happy for the memory to be non-contiguous, then
it should be fine.  If you are using 2.3 kernels, the kiobuf code at

    ftp.uk.linux.org:/pub/linux/sct/fs/raw-io/kiobuf.2.3.99.pre9-2.tar.gz

has a set of helper functions which make it trivial to do this from 
device drivers (and the patch includes a sample driver to show exactly
how it works).

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

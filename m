Date: Wed, 12 Apr 2000 15:45:14 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: page->offset
Message-ID: <20000412154514.G7570@redhat.com>
References: <CA2568BF.00489645.00@d73mta05.au.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA2568BF.00489645.00@d73mta05.au.ibm.com>; from pnilesh@in.ibm.com on Wed, Apr 12, 2000 at 06:34:21PM +0530
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pnilesh@in.ibm.com
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Apr 12, 2000 at 06:34:21PM +0530, pnilesh@in.ibm.com wrote:
> 
> If a file is opened and from an offset which is not page aligned say from
> offset 10.
> When we read this file into the memory page ,where the first byte will be
> loaded into the memory ?
> In 2.2 the first byte of the page will be the 10th byte of the file.
> In 2.3 the first byte will be first byte in the file and 10th byte is the
> 10th in the file.

No.  The cache will always be page aligned in both 2.2 and 2.3 for
all user IO and for all mmap()ed files.  The _only_ case where we
allow non-aligned mappings is when the execve() syscall is executed
on a QMAGIC binary, in which case 2.2 will allow the mapping and
will page the binary in at unaligned offsets when page faults occur.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

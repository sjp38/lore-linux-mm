Date: Wed, 29 Mar 2000 14:49:45 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: how text page of executable are shared ?
Message-ID: <20000329144945.B21920@redhat.com>
References: <CA2568B1.002BB512.00@d73mta05.au.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA2568B1.002BB512.00@d73mta05.au.ibm.com>; from pnilesh@in.ibm.com on Wed, Mar 29, 2000 at 01:16:37PM +0530
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pnilesh@in.ibm.com
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Mar 29, 2000 at 01:16:37PM +0530, pnilesh@in.ibm.com wrote:
> 
> So when no process is pointing to a page in page cache the count will be
> one.
> But what is the difference if we have this to zero any way it is not being
> refernced by any process.
> Or can we have a page cache entry with page count as zero ?

Pages are returned to the system free list as soon as the count reaches
zero.  The swapper does not do that, though: swapped pages are always
entered into the page cache through the swap cache mechanism, and are
finally freed from there.

> Also all the pages which are present in the memory for any process will
> also be part of the page hash queue and if they belong to a file then they
> will also be on the inode queue.

No, anonymous data pages are not usually in the page cache at all.  They
only ever lie in the page cache if there is swapping going on (the VM
effectively treats swapping as a forced mmap() of a page of swap).

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

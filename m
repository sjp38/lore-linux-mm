Date: Wed, 12 Apr 2000 12:06:32 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: page->offset
Message-ID: <20000412120632.E7570@redhat.com>
References: <CA2568BF.00387B64.00@d73mta05.au.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA2568BF.00387B64.00@d73mta05.au.ibm.com>; from pnilesh@in.ibm.com on Wed, Apr 12, 2000 at 03:37:37PM +0530
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pnilesh@in.ibm.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Apr 12, 2000 at 03:37:37PM +0530, pnilesh@in.ibm.com wrote:
> 
> One of the comment in mm.h says that we can have more than one copy of some
> page of an executable or shared lib (not normally).
> 
> Does it have to do something with offet field in page structure ?
> Does it mean that it may happen becoz offset field is not guarenteed to be
> PAGE_SIZE aligned  ?

Correct.  There are some very old binary formats in which the pages
of the executable are not page-aligned.  2.2 still supports them
and allows such binaries to be non-aligned in cache, but there is
no guarantee of cache coherency on such mappings and they are no
longer supported in 2.3.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Date: Wed, 26 Sep 2001 09:53:12 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Process not given >890MB on a 4MB machine ?????????
Message-ID: <20010926095312.O3437@redhat.com>
References: <20010925115914.F3437@redhat.com> <Pine.GSO.4.05.10109251335380.23459-100000@aa.eps.jhu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.05.10109251335380.23459-100000@aa.eps.jhu.edu>; from afei@jhu.edu on Tue, Sep 25, 2001 at 01:36:51PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: afei@jhu.edu
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Joseph A Knapka <jknapka@earthlink.net>, "Gabriel.Leen" <Gabriel.Leen@ul.ie>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Sep 25, 2001 at 01:36:51PM -0400, afei@jhu.edu wrote:

> The current Linux MM design is a 3:1 split of 4G virtual/physical memory.
> So a process, under normal condition cannot get beyond 3G memory
> allocated.

Only on 32-bit machines, and the limit only applies to _mapped_ memory
in process context.  It does not apply to _allocated_ memory --- we
support up to 64GB of physical memory even on Intel.  You just can't
have it all mapped at once, which is why some people use the shared
memory trick to map data in and out of the process's virtual address
space on demand.

Internally, the kernel does not use pointers to memory addresses in
most of the VM.  Instead, it uses 32-bit page numbers to refer to
entire pages, with a separate offset into the page if we need that.
That means that instead of a 12 bit offset and a 20 bit page number
existing in a single 32 bit pointer, we get a full 32 bits of page
number.  That allows the kernel to allocate pages way beyond the
normal 4GB limit of 32 bit pointers.

--Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

Reply-To: Gerrit Huizenga <gh@us.ibm.com>
From: Gerrit Huizenga <gh@us.ibm.com>
Subject: Re: large page patch 
In-reply-to: Your message of Thu, 01 Aug 2002 22:55:05 -0300.
             <Pine.LNX.4.44L.0208012246390.23404-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <31864.1028255392.1@us.ibm.com>
Date: Thu, 01 Aug 2002 19:29:52 -0700
Message-Id: <E17aSCT-0008I0-00@w-gerrit2>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "David S. Miller" <davem@redhat.com>, Andrew Morton <akpm@zip.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rohit.seth@intel.com, sunil.saxena@intel.com, asit.k.mallick@intel.com
List-ID: <linux-mm.kvack.org>

In message <Pine.LNX.4.44L.0208012246390.23404-100000@imladris.surriel.com>, > 
: Rik van Riel writes:
> On Thu, 1 Aug 2002, David S. Miller wrote:
> >    From: Andrew Morton <akpm@zip.com.au>
> 
> >    - Minimal impact on the VM and MM layers
> >
> > Well the downside of this is that it means it isn't transparent
> > to userspace.  For example, specfp2000 results aren't going to
> > improve after installing these changes.  Some of the other large
> > page implementations would.
> 
> We should also take into account that the main application that
> needs large pages for its SHM segments is Oracle, which we don't
> have the source code for so we can't recompile it to use the new
> syscalls introduced by this patch ...

There are quite a few other applications that can benefit from large
page support.  IBM Watson Research published JVM and some scientific
workload results using large pages which showed substantial benefits.
Also, we believe DB2, Domino, other memory piggish apps (e.g. think
scientific) would benefit equally on many architectures.

It would sure be nice if the interface wasn't some kludgey back door
but more integrated with things like mmap() or shm*(), with semantics
and behaviors that were roughly more predictable.  Other than that,
no comments as yet on the patch internals...

gerrit 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

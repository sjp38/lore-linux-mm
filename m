Date: Thu, 1 Aug 2002 22:55:05 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: large page patch
In-Reply-To: <20020801.174301.123634127.davem@redhat.com>
Message-ID: <Pine.LNX.4.44L.0208012246390.23404-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: Andrew Morton <akpm@zip.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rohit.seth@intel.com, sunil.saxena@intel.com, asit.k.mallick@intel.com, gh@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Thu, 1 Aug 2002, David S. Miller wrote:
>    From: Andrew Morton <akpm@zip.com.au>

>    - Minimal impact on the VM and MM layers
>
> Well the downside of this is that it means it isn't transparent
> to userspace.  For example, specfp2000 results aren't going to
> improve after installing these changes.  Some of the other large
> page implementations would.

It also means we can't automatically switch to large pages for
SHM segments, which is the number one area where we need large
pages...

We should also take into account that the main application that
needs large pages for its SHM segments is Oracle, which we don't
have the source code for so we can't recompile it to use the new
syscalls introduced by this patch ...

IMHO we shouldn't blindly decide for (or against!) this patch
but also carefully look at the large page patch from RHAS (which
got added to -aa recently) and the large page patch which IBM
is working on.

kind regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

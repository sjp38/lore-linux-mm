Date: Wed, 22 Mar 2000 22:48:18 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: madvise (MADV_FREE)
Message-ID: <20000322224818.J2850@redhat.com>
References: <20000322190532.A7212@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003221554170.17378-100000@funky.monkey.org> <20000322223351.G2850@redhat.com> <20000322234531.C31795@pcep-jamie.cern.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000322234531.C31795@pcep-jamie.cern.ch>; from jamie.lokier@cern.ch on Wed, Mar 22, 2000 at 11:45:31PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <jamie.lokier@cern.ch>
Cc: Chuck Lever <cel@monkey.org>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Mar 22, 2000 at 11:45:31PM +0100, Jamie Lokier wrote:
> 
> Doesn't this also result in a swap-cache leak, or are orphan swap-cache
> pages reclaimed eventually?

The shrink_mmap() page cache reclaimer is able to pick up any orphaned 
swap cache pages.

> And it's even cheaper to do MADV_FREE so you skip demand-zeroing if
> memory pressure doesn't require that.

Right.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

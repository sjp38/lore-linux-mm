Date: Tue, 21 Mar 2000 02:50:43 +0100
From: Jamie Lokier <jamie.lokier@cern.ch>
Subject: MADV flags as mmap options
Message-ID: <20000321025043.D4271@pcep-jamie.cern.ch>
References: <20000320135939.A3390@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003201318050.23474-100000@funky.monkey.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.BSO.4.10.10003201318050.23474-100000@funky.monkey.org>; from Chuck Lever on Mon, Mar 20, 2000 at 02:09:26PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

While we're here :-)

It seems to me that a lot of the time, madvise() will be called
immediately after mmap() on the same region.

How about making the MADV_ flags distinct from the MAP_ flags, and
arranging that you may pass MADV_ flags to mmap().  If it sees any, it
does the mapping and follows it by the corresponding madvise_vma call.

(Only really useful for MADV_RANDOM and MADV_SEQUENTIAL).

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

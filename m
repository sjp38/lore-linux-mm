Date: Tue, 17 Aug 1999 01:49:41 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [bigmem-patch] 4GB with Linux on IA32
In-Reply-To: <199908162328.QAA24338@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.9908170134460.13970-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: alan@lxorguk.ukuu.org.uk, torvalds@transmeta.com, sct@redhat.com, Gerhard.Wichert@pdb.siemens.de, Winfried.Gerhard@pdb.siemens.de, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Aug 1999, Kanoj Sarcar wrote:

>I was also talking about drivers which assume that all of memory is
>direct mapped. For example, __va and __pa assume this. There might be 
>other macros/procedures which have the same assumption built in. 
>Basically, anything that is dependent on PAGE_OFFSET needs to be
>checked. 

Only places that may deal with bigmem pages and the core of the kernel
must be checked. I don't exclude there still something to fix (as happened
with kernel/ptrace.c and /proc/*/mem) but with the current design we
shouldn't need to touch the device drivers at all.

The only real problem currently seems to be raw-io to me... (hints?)

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

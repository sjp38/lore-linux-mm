Date: Mon, 16 Aug 1999 22:34:56 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [bigmem-patch] 4GB with Linux on IA32
In-Reply-To: <199908161843.LAA76017@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.9908162217560.4139-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: torvalds@transmeta.com, sct@redhat.com, Gerhard.Wichert@pdb.siemens.de, Winfried.Gerhard@pdb.siemens.de, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Aug 1999, Kanoj Sarcar wrote:

>For example, driver and fs code which operate on user pages might
>need to be changed. I hear that Stephen's rawio code made it into

Yes. Or better I don't want to change the lowlevel blockdevice internals
so I give to such code always regular pages to eat.

>2.3.13, so would your patch work if a rawio request was made to
>a range of user pages that were in bigmem area? Also, debuggers

No idea about rawio (I have not yet read the rawio code).

For debuggers I'll add a kmap to access_one_page in ptrace.c, thanks.

>Basically, any code that does a pte_page and similar calls is suspect, 
>right?

Yes it is. But only if such code can deal with anonymous or shm or
vmalloced pages.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

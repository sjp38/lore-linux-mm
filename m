From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199908161843.LAA76017@google.engr.sgi.com>
Subject: Re: [bigmem-patch] 4GB with Linux on IA32
Date: Mon, 16 Aug 1999 11:43:33 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.10.9908161622130.1937-100000@laser.random> from "Andrea Arcangeli" at Aug 16, 99 06:29:30 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: torvalds@transmeta.com, sct@redhat.com, Gerhard.Wichert@pdb.siemens.de, Winfried.Gerhard@pdb.siemens.de, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea,

I believe you are on the right track, by marking bigmem pages in
the flags, and requiring a mapping call before the kernel can access
the contents of the page. I have a few issues though. I haven't looked
at your code yet, so it is possible that you may have taken care
of some of this already.

For example, driver and fs code which operate on user pages might
need to be changed. I hear that Stephen's rawio code made it into
2.3.13, so would your patch work if a rawio request was made to
a range of user pages that were in bigmem area? Also, debuggers
want to look at user memory, so they would also need to map the
pages. Are there any other cases where a driver might want to 
look at such bigmem user pages (probably not in the context of
the process, in which case the uaccess functions are usable?).
Basically, any code that does a pte_page and similar calls is suspect, 
right?

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/

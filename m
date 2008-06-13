Date: Fri, 13 Jun 2008 00:16:44 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG] 2.6.26-rc5-mm3 kernel BUG at mm/filemap.c:575!
Message-Id: <20080613001644.b1b87b0e.akpm@linux-foundation.org>
In-Reply-To: <4041.1213330723@turing-police.cc.vt.edu>
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org>
	<4850E1E5.90806@linux.vnet.ibm.com>
	<4041.1213330723@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Fri, 13 Jun 2008 00:18:43 -0400 Valdis.Kletnieks@vt.edu wrote:

> On Thu, 12 Jun 2008 14:14:21 +0530, Kamalesh Babulal said:
> > Hi Andrew,
> > 
> > 2.6.26-rc5-mm3 kernel panics while booting up on the x86_64
> > machine. Sorry the console is bit overwritten for the first few lines.
> 
> > no fstab.kernel BUG at mm/filemap.c:575!
> 
> For whatever it's worth, I'm seeing the same thing on my x86_64 laptop.
> -rc5-mm2 works OK, I'm going to try to bisect it tonight.

ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.26-rc5/2.6.26-rc5-mm3/hot-fixes/fix-double-unlock_page-in-2626-rc5-mm3-kernel-bug-at-mm-filemapc-575.patch is said to "fix" it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

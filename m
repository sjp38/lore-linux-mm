Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 7F7A06B0068
	for <linux-mm@kvack.org>; Sat, 22 Dec 2012 08:31:48 -0500 (EST)
Date: Sat, 22 Dec 2012 15:31:45 +0200
From: Aaro Koskinen <aaro.koskinen@iki.fi>
Subject: Re: 3.8-rc1 build failure with MIPS/SPARSEMEM
Message-ID: <20121222133145.GC6847@blackmetal.musicnaut.iki.fi>
References: <20121222122757.GB6847@blackmetal.musicnaut.iki.fi>
 <20121222131022.GA16364@otc-wbsnb-06>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121222131022.GA16364@otc-wbsnb-06>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mips@linux-mips.org

Hi,

On Sat, Dec 22, 2012 at 03:10:23PM +0200, Kirill A. Shutemov wrote:
> On Sat, Dec 22, 2012 at 02:27:57PM +0200, Aaro Koskinen wrote:
> > It looks like commit 816422ad76474fed8052b6f7b905a054d082e59a
> > (asm-generic, mm: pgtable: consolidate zero page helpers) broke
> > MIPS/SPARSEMEM build in 3.8-rc1:
> 
> Could you try this:
> 
> http://permalink.gmane.org/gmane.linux.kernel/1410981

It's not helping. And if you look at the error, it shows linux/mm.h is
already there?

[...]
In file included from /home/aaro/git/linux/arch/mips/include/asm/pgtable.h:388:0,
                 from include/linux/mm.h:44,
                 from arch/mips/kernel/asm-offsets.c:14:
[...]

A.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Wed, 15 Oct 2003 09:55:08 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.6.0-test7-mm1
Message-ID: <20031015165508.GA723@holomorphy.com>
References: <20031015013649.4aebc910.akpm@osdl.org> <1066232576.25102.1.camel@telecentrolivre>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1066232576.25102.1.camel@telecentrolivre>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Luiz Capitulino <lcapitulino@prefeitura.sp.gov.br>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 15, 2003 at 01:42:56PM -0200, Luiz Capitulino wrote:
> Andrew (I again),
> Em Qua, 2003-10-15 ?s 06:36, Andrew Morton escreveu:
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test7/2.6.0-test7-mm1
> getting this while umounting my /home (ext3) partition:
> # umount /dev/hda4
> Unable to handle kernel paging request at virtual address c282deac
> printing eip:
> c0164104
> 00007063
> *pte = 0282d000
> Oops: 0002 [#1]
> DEBUG_PAGEALLOC
> CPU:    0
> EIP:    0060:[generic_forget_inode+84/352]    Not tainted VLI
> EFLAGS: 00010246
> EIP is at generic_forget_inode+0x54/0x160

Okay, this one's me. I should have tried DEBUG_PAGEALLOC when testing.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

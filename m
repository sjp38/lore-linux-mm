Date: Mon, 10 Mar 2008 19:08:43 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [0/13] General DMA zone rework
Message-ID: <20080310180843.GC28780@one.firstfloor.org>
References: <200803071007.493903088@firstfloor.org> <20080307175148.3a49d8d3@mandriva.com.br> <20080308004654.GQ7365@one.firstfloor.org> <20080310150316.752e4489@mandriva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080310150316.752e4489@mandriva.com.br>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luiz Fernando N. Capitulino" <lcapitulino@mandriva.com.br>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>  I saw that the patches you've posted here are only a subset of
> the patches you have in your FTP. Should I test all the patches

The ftp directory contains the SCSI patchkit (which I have been
posting to linux-scsi for quite some time, but it didn't get applied
yet) and the block patchkit (which hit linux-kernel earlier,
but was unfortunately not graced by a reply by the block maintainer so far) 

> you have or only the subset you posted?

Best you test all together. The subsets are independent
(as in kernel should work with any subset of them), but 
they all clean up DMA memory related issues.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Subject: Re: 2.6.0-test3-mm1
From: Luiz Capitulino <lcapitulino@prefeitura.sp.gov.br>
In-Reply-To: <20030809203943.3b925a0e.akpm@osdl.org>
References: <20030809203943.3b925a0e.akpm@osdl.org>
Content-Type: text/plain; charset=iso-8859-1
Message-Id: <1060610602.6452.3.camel@lorien>
Mime-Version: 1.0
Date: 11 Aug 2003 11:03:23 -0300
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew,

Em Dom, 2003-08-10 as 00:39, Andrew Morton escreveu:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test3/2.6.0-test3-mm1

 I'm getting this warning with gcc-3.3.1:

drivers/char/keyboard.c: In function `k_fn':
drivers/char/keyboard.c:665: warning: comparison is always true due
to limited range of data type

 gcc seems right, because the ``value'' variable only go to
255 and the size of ``func_table'' in my system is 256.

 Even if gcc transforms unsigned char to a higher in this case, its
not solve the problem, because the value in ``value'' will use only
8 bits (this is made by the K_VAL() macro).

 thanks,

PS: I'm getting this with 2.6.0-test3 too.

-- 
Luiz Fernando N. Capitulino

<lcapitulino@prefeitura.sp.gov.br>
<http://www.telecentros.sp.gov.br>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Message-ID: <47B1B7F4.8080009@bull.net>
Date: Tue, 12 Feb 2008 16:15:00 +0100
From: Nadia Derbey <Nadia.Derbey@bull.net>
MIME-Version: 1.0
Subject: Re: [PATCH 7/8] Do not recompute msgmni anymore if explicitely set
 by user
References: <20080211141646.948191000@bull.net>	<20080211141816.094061000@bull.net>	<20080211122408.5008902f.akpm@linux-foundation.org>	<47B167AF.6010008@bull.net> <20080212014444.8bc3791b.akpm@linux-foundation.org>
In-Reply-To: <20080212014444.8bc3791b.akpm@linux-foundation.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, y-goto@jp.fujitsu.com, linux-mm@kvack.org, containers@lists.linux-foundation.org, matthltc@us.ibm.com, cmm@us.ibm.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Tue, 12 Feb 2008 10:32:31 +0100 Nadia Derbey <Nadia.Derbey@bull.net> wrote:
> 
> 
>>it builds fine, modulo some changes in ipv4 and ipv6 (see attached patch 
>>- didn't find it in the hot fixes).
> 
> 
> OK, thanks for checking.  Did you confirm that we don't have unneeded code
> in vmlinux when CONFIG_PROCFS=n?  I guess before-and-after comparison of
> the size(1) output would tell us.
> 
> Those networking build problems appear to have already been fixed.
> 
> In future, please quote the compiler error output in the changelog when
> sending build fixes or warning fixes, thanks.
> 
> 
> 

BEFORE:

lkernel@akt$ size vmlinux
    text    data     bss     dec     hex filename
4318525  454484  462848 5235857  4fe491 vmlinux


AFTER:

lkernel@akt$ size vmlinux
    text    data     bss     dec     hex filename
4323161  454484  462848 5240493  4ff6ad vmlinux

which makes it +4636 = +0.11%

I've got the details for */built-in.o if needed.


Regards,
Nadia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

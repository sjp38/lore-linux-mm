Subject: Re: 2.6.0-test4-mm2
From: Luiz Capitulino <lcapitulino@prefeitura.sp.gov.br>
In-Reply-To: <20030826221053.25aaa78f.akpm@osdl.org>
References: <20030826221053.25aaa78f.akpm@osdl.org>
Content-Type: text/plain; charset=iso-8859-1
Message-Id: <1062075227.422.2.camel@lorien>
Mime-Version: 1.0
Date: Thu, 28 Aug 2003 09:53:48 -0300
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew,

Em Qua, 2003-08-27 as 02:10, Andrew Morton escreveu: 
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test4/2.6.0-test4-mm2/

when using the hdparm program, thus:

# hdparm /dev/hda

I'm getting this:

Oops: 0000 [#1]
DEBUG_PAGEALLOC
CPU:    0
EIP:    0060:[<c0248fc8>]    Not tainted VLI
EFLAGS: 00010246
EIP is at generic_ide_ioctl+0x2b8/0x7b0
eax: 00000000   ebx: 00000000   ecx: 00000000   edx: 080539fc
esi: c78f9004   edi: 08053a04   ebp: c5677f68   esp: c5677f2c
ds: 007b   es: 007b   ss: 0068
Process hdparm (pid: 347, threadinfo=c5676000 task=c5685000)
Stack: c03fb98c 00000301 c5677f50 fffffff2 080539fe 00000000 00000019
c03fb98c
       c01f7a90 3f4df842 232d3ea0 00000000 c78f9004 c7a99004 c6317094
c5677f90
       c022a5a7 c78f9004 00000301 080539fc 080539fc 00000046 00000301
c672ab94
Call Trace:
[<c01f7a90>] write_chan+0x0/0x260
[<c022a5a7>] blkdev_ioctl+0xa7/0x447
[<c015cc61>] sys_ioctl+0xb1/0x230
[<c02ff623>] syscall_call+0x7/0xb

Code: 85 d5 fd ff ff c7 45 d0 f2 ff ff ff 8b 45 10 83 c0 04 89 c7 83 c7
04 19 d2
39 79 18 83 da 00 85 d2 75 10 8b 46 38 89 d9 8b 55 10 <8b> 00 89 42 04
89 4d d0
8b 45 d0 ba f2 ff ff ff 85 c0 0f 44 d3
Segmentation Fault

It does not happens in current bk2. hdparm version is 5.4.


-- 
Luiz Fernando N. Capitulino

<lcapitulino@prefeitura.sp.gov.br>
<http://www.telecentros.sp.gov.br>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

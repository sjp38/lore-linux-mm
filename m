Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D52328D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 09:17:05 -0400 (EDT)
Received: by qyk2 with SMTP id 2so3309501qyk.14
        for <linux-mm@kvack.org>; Wed, 30 Mar 2011 06:17:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTikX0jxdkyYgPoqjvC5HzY8VydTbFh_gFDzM8zJ7@mail.gmail.com>
References: <9bde694e1003020554p7c8ff3c2o4ae7cb5d501d1ab9@mail.gmail.com>
	<AANLkTinnqtXf5DE+qxkTyZ9p9Mb8dXai6UxWP2HaHY3D@mail.gmail.com>
	<1300960540.32158.13.camel@e102109-lin.cambridge.arm.com>
	<AANLkTim139fpJsMJFLiyUYvFgGMz-Ljgd_yDrks-tqhE@mail.gmail.com>
	<1301395206.583.53.camel@e102109-lin.cambridge.arm.com>
	<AANLkTim-4v5Cbp6+wHoXjgKXoS0axk1cgQ5AHF_zot80@mail.gmail.com>
	<1301399454.583.66.camel@e102109-lin.cambridge.arm.com>
	<AANLkTin0_gT0E3=oGyfMwk+1quqonYBExeN9a3=v=Lob@mail.gmail.com>
	<AANLkTi=gMP6jQuQFovfsOX=7p-SSnwXoVLO_DVEpV63h@mail.gmail.com>
	<1301476505.29074.47.camel@e102109-lin.cambridge.arm.com>
	<AANLkTi=YB+nBG7BYuuU+rB9TC-BbWcJ6mVfkxq0iUype@mail.gmail.com>
	<AANLkTi=L0zqwQ869khH1efFUghGeJjoyTaBXs-O2icaM@mail.gmail.com>
	<AANLkTi=vcn5jHpk0O8XS9XJ8s5k-mCnzUwu70mFTx4=g@mail.gmail.com>
	<1301485085.29074.61.camel@e102109-lin.cambridge.arm.com>
	<AANLkTikXfVNkyFE2MpW9ZtfX2G=QKvT7kvEuDE-YE5xO@mail.gmail.com>
	<1301488032.3283.42.camel@edumazet-laptop>
	<AANLkTikX0jxdkyYgPoqjvC5HzY8VydTbFh_gFDzM8zJ7@mail.gmail.com>
Date: Wed, 30 Mar 2011 14:17:03 +0100
Message-ID: <AANLkTi=RXoEOVmTPiL=dfO97aOVKWOJWE7hoQduPPsCZ@mail.gmail.com>
Subject: Re: kmemleak for MIPS
From: Maxin John <maxin.john@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Baluta <daniel.baluta@gmail.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, naveen yadav <yad.naveen@gmail.com>, linux-mips@linux-mips.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Eric Dumazet <eric.dumazet@gmail.com>

Hi,

I have compiled the kernel with below given modification in .config

CONFIG_CMDLINE="uhash_entries=256"

After booting with the new kernel, the "kmemleak" no longer complains
about the "udp_table_init".
However it do report another possible leak :)

debian-mips:~# cat /sys/kernel/debug/kmemleak
unreferenced object 0x8f085000 (size 4096):
  comm "swapper", pid 1, jiffies 4294937670 (age 1043.280s)
  hex dump (first 32 bytes):
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<801ac7a8>] __kmalloc+0x130/0x180
    [<80532500>] flow_cache_cpu_prepare+0x50/0xa8
    [<8052378c>] flow_cache_init_global+0x90/0x138
    [<80100584>] do_one_initcall+0x174/0x1e0
    [<8050c348>] kernel_init+0xe4/0x174
    [<80103d4c>] kernel_thread_helper+0x10/0x18
debian-mips:~#

> So, I guess everything is fine regarding udp_init_table. We can move on,
> integrating MIPS support for kmemleak :).
>

I completely agree with Daniel. Shall we move on and integrate the
kmemleak support for MIPS ?

Cheers,
Maxin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

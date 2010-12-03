Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 284B36B008C
	for <linux-mm@kvack.org>; Fri,  3 Dec 2010 16:43:28 -0500 (EST)
Received: by qwk4 with SMTP id 4so240125qwk.14
        for <linux-mm@kvack.org>; Fri, 03 Dec 2010 13:43:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201012030107.oB317ZSW019223@imap1.linux-foundation.org>
References: <201012030107.oB317ZSW019223@imap1.linux-foundation.org>
Date: Fri, 3 Dec 2010 22:43:25 +0100
Message-ID: <AANLkTik3uaOV5U8H30p9AyFsa_HzVMsyqdhxhGBFhxMP@mail.gmail.com>
Subject: Re: mmotm 2010-12-02-16-34 uploaded
From: Zimny Lech <napohybelskurwysynom2010@gmail.com>
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Ave,

2010/12/3  <akpm@linux-foundation.org>:
> The mm-of-the-moment snapshot 2010-12-02-16-34 has been uploaded to
>

23 builds, and only known problems, nothing new

arch/x86/built-in.o: In function `kvm_smp_prepare_boot_cpu':
kvm.c:(.init.text+0xdb49): undefined reference to `kvm_register_clock'
make[1]: *** [.tmp_vmlinux1] Error 1
make: *** [sub-make] Error 2

drivers/built-in.o: In function `pch_uart_shutdown':
pch_uart.c:(.text+0x1a9921): undefined reference to `dma_release_channel'
pch_uart.c:(.text+0x1a9939): undefined reference to `dma_release_channel'
drivers/built-in.o: In function `pch_uart_startup':
pch_uart.c:(.text+0x1a9bdd): undefined reference to `__dma_request_channel'
pch_uart.c:(.text+0x1a9c3e): undefined reference to `__dma_request_channel'
pch_uart.c:(.text+0x1a9e38): undefined reference to `dma_release_channel'
make[1]: *** [.tmp_vmlinux1] Error 1
make: *** [sub-make] Error 2

make[4]: *** No rule to make target
`drivers/scsi/aic7xxx/aicasm/*.[chyl]', needed by
`drivers/scsi/aic7xxx/aicasm/aicasm'.  Stop.
make[3]: *** [drivers/scsi/aic7xxx] Error 2
make[2]: *** [drivers/scsi] Error 2
make[1]: *** [drivers] Error 2
make: *** [sub-make] Error 2




--=20
Slawa!
Zimny "Spie dziadu!" Lech z Wawelu

Piekielny strach zagrzmia=B3
Patrz=EA na sufit
Krew tam
Strz=EApy g=B3=F3w w b=F3lach j=EAcz=B1 co=B6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

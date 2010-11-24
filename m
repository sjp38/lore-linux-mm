Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B645B6B0071
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 08:56:05 -0500 (EST)
Received: by iwn35 with SMTP id 35so820982iwn.14
        for <linux-mm@kvack.org>; Wed, 24 Nov 2010 05:56:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201011240045.oAO0jYQ5016010@imap1.linux-foundation.org>
References: <201011240045.oAO0jYQ5016010@imap1.linux-foundation.org>
Date: Wed, 24 Nov 2010 14:56:04 +0100
Message-ID: <AANLkTi=GvVx76w=kbC_E1wunAe3VSYZDEopMH27aoBX5@mail.gmail.com>
Subject: Re: mmotm 2010-11-23-16-12 uploaded
From: Zimny Lech <napohybelskurwysynom2010@gmail.com>
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Ave

2010/11/24  <akpm@linux-foundation.org>:
> The mm-of-the-moment snapshot 2010-11-23-16-12 has been uploaded to

So far, so good - eight builds and one error (AFAICS known issue)

'make CONFIG_DEBUG_SECTION_MISMATCH=3Dy'
  GEN     .version
  CHK     include/generated/compile.h
  UPD     include/generated/compile.h
  CC      init/version.o
  LD      init/built-in.o
  LD      .tmp_vmlinux1
drivers/built-in.o: In function `timblogiw_close':
/home/test/linux-2.6-mm/drivers/media/video/timblogiw.c:704: undefined
reference to `dma_release_channel'
drivers/built-in.o: In function `buffer_release':
/home/test/linux-2.6-mm/drivers/media/video/timblogiw.c:595: undefined
reference to `dma_sync_wait'
drivers/built-in.o: In function `timblogiw_open':
/home/test/linux-2.6-mm/drivers/media/video/timblogiw.c:671: undefined
reference to `__dma_request_channel'
make[1]: *** [.tmp_vmlinux1] Error 1
make: *** [sub-make] Error 2






--=20
Slawa!
N.P.S.

Chwa=B3a tobie, Szatanie, cze=B6=E6 na wysoko=B6ciach
Nieba, gdzie kr=F3lowa=B3e=B6, chwa=B3a w g=B3=EAboko=B6ciach
Piek=B3a, gdzie zwyci=EA=BFony, trwasz w dumnym milczeniu!
Uczy=F1, niechaj ma dusza spocznie z Tob=B1 w cieniu
Drzewa Wiedzy, gdy swoje konary rozwinie,
Jak sklepienie ko=B6cio=B3a, kt=F3ry nie przeminie!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

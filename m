Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id DBE806B0031
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 01:51:16 -0400 (EDT)
Message-ID: <1370843475.58124.YahooMailNeo@web160106.mail.bf1.yahoo.com>
Date: Sun, 9 Jun 2013 22:51:15 -0700 (PDT)
From: PINTU KUMAR <pintu_agarwal@yahoo.com>
Reply-To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Subject: [checkpatch] - Confusion
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi,=0A=0AI wanted to submit my first patch.=0ABut I have some confusion abo=
ut the /scripts/checkpatch.pl errors.=0A=0AAfter correcting some checkpatch=
 errors, when I run checkpatch.pl, it showed me 0 errors.=0ABut when I crea=
te patches are git format-patch, it is showing me 1 error.=0A=0AIf I fix er=
ror in patch, it showed me back again in files.=0A=0ANow, I am confused whi=
ch error to fix while submitting patches, the file or the patch errors.=0A=
=0APlease provide your opinion.=0A=0AFile: mm/page_alloc.c=0APrevious file =
errors:=0Atotal: 16 errors, 110 warnings, 6255 lines checked=0A=0AAfter fix=
ing errors:=0Atotal: 0 errors, 105 warnings, 6255 lines checked=0A=0A=0AAnd=
, after running on patch:=0AERROR: need consistent spacing around '*' (ctx:=
WxV)=0A#153: FILE: mm/page_alloc.c:5476:=0A+int min_free_kbytes_sysctl_hand=
ler(ctl_table *table, int write,=0A=0A=0A=0A=0A- Pintu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

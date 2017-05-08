Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id BFA836B03B9
	for <linux-mm@kvack.org>; Mon,  8 May 2017 05:27:41 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id m68so8297368wmg.4
        for <linux-mm@kvack.org>; Mon, 08 May 2017 02:27:41 -0700 (PDT)
Received: from rrzmta2.uni-regensburg.de (rrzmta2.uni-regensburg.de. [194.94.155.52])
        by mx.google.com with ESMTPS id p18si14893924wrc.79.2017.05.08.02.27.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 May 2017 02:27:40 -0700 (PDT)
Received: from rrzmta2.uni-regensburg.de (localhost [127.0.0.1])
	by localhost (Postfix) with SMTP id 97AC47331E
	for <linux-mm@kvack.org>; Mon,  8 May 2017 11:27:39 +0200 (CEST)
Received: from gwsmtp1.uni-regensburg.de (gwsmtp1.uni-regensburg.de [132.199.5.51])
	by rrzmta2.uni-regensburg.de (Postfix) with ESMTP id 7CAE5732A1
	for <linux-mm@kvack.org>; Mon,  8 May 2017 11:27:39 +0200 (CEST)
Message-Id: <59103A09020000D3000127FA@gwsmtp1.uni-regensburg.de>
Date: Mon, 08 May 2017 11:27:37 +0200
From: "Stoermeldung Infrastruktur-Ukr"
 <Stoermeldung.Infrastruktur-Ukr@rz.uni-regensburg.de>
Subject: Q: si_code for SIGBUS caused by mmap() write error
References: <59103A09020000D3000127FA@gwsmtp1.uni-regensburg.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=__Part023A4619.0__="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Ulrich Windl <Ulrich.Windl@rz.uni-regensburg.de>, linux-kernel@vger.kernel.org

This is a MIME message. If you are reading this text, you may want to 
consider changing to a mail reader or gateway that understands how to 
properly handle MIME multipart messages.

--=__Part023A4619.0__=
Content-Type: multipart/alternative; boundary="=__Part023A4619.1__="

--=__Part023A4619.1__=
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi!

I observed this for 3.0.101-97 kernel (SLES11 SP4, x86_64): When a =
mmap()ed file has a write error (e.g. bad sector), the program is =
terminated with SIGBUS. Trying to handle the situation, I noticed that the =
error code in siginfo is 2 (BUS_ADRERR, nonexistent physical address). My =
expectation was that the error would be 3 (BUS_OBJERR, object-specific =
hardware error).

For debugging I created this dummy device with a bad block:
DEV=3Dbad_disk
dmsetup create "$DEV" <<EOF
0 8 zero
8 1 error
9 255 zero
EOF

The kernel error logged is " kernel: [2932614.419355] Buffer I/O error on =
device dm-8, logical block 1"

Is my expectation on the si_code wrong, or is the implementation wrong?

At a quick glance at do_sigbus() of /usr/src/linux/arch/x86/mm/fault.c I =
see that only codes BUS_ADRERR (default) and BUS_MCEERR_AR are used. =
However I don't know whether I looked at the correct source.
(The code in 4.4.62 still looks similar)

Regards,
Ulrich Windl
P.S: Keep me on CC: in your replies, please!

--=__Part023A4619.1__=
Content-Type: text/html; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Description: HTML

<html><head>=0A=0A<meta name=3D"Generator" content=3D"Novell Groupwise =
Client (Version 14.2.1  Build: 125229)">=0A<meta http-equiv=3D"Content-Type=
" content=3D"text/html; charset=3Dutf-8"></head>=0A<body style=3D"font: =
10pt/normal Segoe UI; font-size-adjust: none; font-stretch: normal;"><div =
class=3D"GroupWiseMessageBody" id=3D"GroupWiseSection_1494234757000_Ulrich.=
Windl@rz.uni-regensburg.de_DE2C7590129600009A2986C8FF4E000A_"><div>Hi!</div=
><div><br></div><div>I observed this for  3.0.101-97 kernel (SLES11 SP4, =
x86_64): When a mmap()ed file has a write error (e.g. bad sector), the =
program is terminated with SIGBUS. Trying to handle the situation, I =
noticed that the error code in siginfo is 2 (BUS_ADRERR, nonexistent =
physical address). My expectation was that the error would be 3 (BUS_OBJERR=
, object-specific hardware error).</div><div><br></div><div>For debugging =
I created this dummy device with a bad block:</div><div>DEV=3Dbad_disk<br>d=
msetup create "$DEV" &lt;&lt;EOF<br>0 8 zero<br>8 1 error<br>9 255 =
zero<br>EOF</div><div><br></div><div>The kernel error logged is " kernel: =
[2932614.419355] Buffer I/O error on device dm-8, logical block 1"</div><di=
v><br></div><div>Is my expectation on the si_code wrong, or is the =
implementation wrong?</div><div><br></div><div>At a quick glance at =
do_sigbus() of /usr/src/linux/arch/x86/mm/fault.c I see that only codes =
BUS_ADRERR (default) and BUS_MCEERR_AR are used. However I don't know =
whether I looked at the correct source.</div><div>(The code in 4.4.62 =
still looks similar)</div><div><br></div><div>Regards,</div><div>Ulrich =
Windl</div><div>P.S: Keep me on CC: in your replies, please!<br></div></div=
></body></html>

--=__Part023A4619.1__=--

--=__Part023A4619.0__=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

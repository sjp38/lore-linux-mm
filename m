Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 43CA46B006E
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 05:06:25 -0400 (EDT)
References: <1347887746.22926.YahooMailNeo@web160105.mail.bf1.yahoo.com>
Message-ID: <1347959184.19552.YahooMailNeo@web160104.mail.bf1.yahoo.com>
Date: Tue, 18 Sep 2012 02:06:24 -0700 (PDT)
From: PINTU KUMAR <pintu_agarwal@yahoo.com>
Reply-To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Subject: Re: Info required: Tracking memcpy operation in user/kernel
In-Reply-To: <1347887746.22926.YahooMailNeo@web160105.mail.bf1.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi,=0A=0AI wanted to track down memcpy operations of various user applicati=
ons/lib or kernel modules.=0AIn one of the scenarios there are too many mem=
cpy operations used in our platform.=0AAnd we wanted to track which appln/l=
ib and kernel modules doing memcpy and of what size.=0A=0AIf anybody is awa=
re of any utility please let me know.=0A=0AOr,=0Aplease let me know how to =
track memcpy from kernel space may be using some kernel module.=0A=0A=0ATha=
nk You!=0AWith Regards,=0APintu=0A=A0=0A=A0=0A=0A=0A>______________________=
__________=0A>From: PINTU KUMAR <pintu_agarwal@yahoo.com>=0A>To: "linux-mm@=
kvack.org" <linux-mm@kvack.org>; "linux-kernel@vger.kernel.org" <linux-kern=
el@vger.kernel.org> =0A>Sent: Monday, 17 September 2012 6:45 PM=0A>Subject:=
 Info required: Tracking memcpy operation in user/kernel=0A>=0A>=0A>Hi,=0A>=
=0A>I wanted to track down memcpy operations of various user applications/l=
ib or kernel modules.=0A>In one of the scenarios there are too many memcpy =
operations used in our platform.=0A>And we wanted to track which appln/lib =
and kernel modules doing memcpy and of what size.=0A>=0A>If anybody is awar=
e of any utility please let me know.=0A>=0A>Or,=0A>please let me know how t=
o track memcpy from kernel space may be using some kernel module.=0A>=0A>=
=0A>Thank You!=0A>With Regards,=0A>Pintu=0A>=A0=0A>=0A>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

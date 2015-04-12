Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id D2DAD6B0038
	for <linux-mm@kvack.org>; Sun, 12 Apr 2015 03:17:12 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so68081274pac.1
        for <linux-mm@kvack.org>; Sun, 12 Apr 2015 00:17:12 -0700 (PDT)
Received: from COL004-OMC1S5.hotmail.com (col004-omc1s5.hotmail.com. [65.55.34.15])
        by mx.google.com with ESMTPS id cg8si10211345pac.134.2015.04.12.00.17.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 12 Apr 2015 00:17:12 -0700 (PDT)
Message-ID: <COL130-W1779F50C23B3E7EA23A707BAF80@phx.gbl>
From: ZhangNeil <neilzhang1123@hotmail.com>
Subject: RE: [PATCH v2] mm: show free pages per each migrate type
Date: Sun, 12 Apr 2015 07:17:11 +0000
In-Reply-To: <20150409212441.a64c3fe0.akpm@linux-foundation.org>
References: 
 <BLU436-SMTP78227860F3E4FAF236A85CBAFB0@phx.gbl>,<20150409134701.5903cb5217f5742bbacc73da@linux-foundation.org>,<COL130-W536B434DEADC19798C2A9FBAFA0@phx.gbl>,<20150409212441.a64c3fe0.akpm@linux-foundation.org>
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

=0A=
=0A=
----------------------------------------=0A=
> Date: Thu=2C 9 Apr 2015 21:24:41 -0700=0A=
> From: akpm@linux-foundation.org=0A=
> To: neilzhang1123@hotmail.com=0A=
> CC: linux-mm@kvack.org=3B linux-kernel@vger.kernel.org=0A=
> Subject: Re: [PATCH v2] mm: show free pages per each migrate type=0A=
>=0A=
> On Fri=2C 10 Apr 2015 04:16:15 +0000 ZhangNeil <neilzhang1123@hotmail.com=
> wrote:=0A=
>=0A=
>>> I think we can eliminate nr_free[][]:=0A=
>>=0A=
>> what about make it as global__variable?=0A=
>=0A=
> That isn't as good - it permanently consumes memory and really requires=
=0A=
> new locking to protect the array from concurrent callers.=0A=
>=0A=
=0A=
Then it may need to change the code a lot.=0A=
=0A=
BTW:=0A=
I calculate the=A0nr_free[][] again=2C it is an 6x11 array of 8 in the wors=
t case=2C that is 528B=2C is it acceptable?=0A=
=0A=
Best Regards=2C=0A=
Neil Zhang 		 	   		  =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

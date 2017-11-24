Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id CDED66B025F
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 08:42:18 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id d86so8014055pfk.19
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 05:42:18 -0800 (PST)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id y14si18356469pgs.11.2017.11.24.05.42.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Nov 2017 05:42:17 -0800 (PST)
Received: from epcas5p1.samsung.com (unknown [182.195.41.39])
	by mailout3.samsung.com (KnoxPortal) with ESMTP id 20171124134215epoutp03f3876ae69f6fa4fdc800206fe8f323f1~6CWCCNELy2089920899epoutp03t
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 13:42:15 +0000 (GMT)
Mime-Version: 1.0
Subject: RE: Re: Re: [PATCH 1/1] stackdepot: interface to check entries and
 size of stackdepot.
Reply-To: v.narang@samsung.com
From: Vaneet Narang <v.narang@samsung.com>
In-Reply-To: <20171124124429.juonhyw4xbqc65u7@dhcp22.suse.cz>
Message-ID: <20171124133025epcms5p7dc263c4a831552245e60193917a45b07@epcms5p7>
Date: Fri, 24 Nov 2017 13:30:25 +0000
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="utf-8"
References: <20171124124429.juonhyw4xbqc65u7@dhcp22.suse.cz>
	<CACT4Y+bF7TGFS+395kyzdw21M==ECgs+dCjV0e3Whkvm1_piDA@mail.gmail.com>
	<20171123162835.6prpgrz3qkdexx56@dhcp22.suse.cz>
	<1511347661-38083-1-git-send-email-maninder1.s@samsung.com>
	<20171124094108epcms5p396558828a365a876d61205b0fdb501fd@epcms5p3>
	<20171124095428.5ojzgfd24sy7zvhe@dhcp22.suse.cz>
	<20171124115707epcms5p4fa19970a325e87f08eadb1b1dc6f0701@epcms5p4>
	<CGME20171122105142epcas5p173b7205da12e1fc72e16ec74c49db665@epcms5p7>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Maninder Singh <maninder1.s@samsung.com>, "kstewart@linuxfoundation.org" <kstewart@linuxfoundation.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "jkosina@suse.cz" <jkosina@suse.cz>, "pombredanne@nexb.com" <pombredanne@nexb.com>, "jpoimboe@redhat.com" <jpoimboe@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "guptap@codeaurora.org" <guptap@codeaurora.org>, "vinmenon@codeaurora.org" <vinmenon@codeaurora.org>, AMIT SAHRAWAT <a.sahrawat@samsung.com>, PANKAJ MISHRA <pankaj.m@samsung.com>, Lalit Mohan Tripathi <lalit.mohan@samsung.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, kasan-dev <kasan-dev@googlegroups.com>

Hi Michal,

>>=C2=A0We=C2=A0have=C2=A0been=C2=A0getting=C2=A0similar=C2=A0kind=C2=A0of=
=C2=A0such=C2=A0entries=C2=A0and=C2=A0eventually=0D=0A>>=C2=A0stackdepot=C2=
=A0reaches=C2=A0Max=C2=A0Cap.=C2=A0So=C2=A0we=C2=A0found=C2=A0this=C2=A0int=
erface=C2=A0useful=C2=A0in=C2=A0debugging=0D=0A>>=C2=A0stackdepot=C2=A0issu=
e=C2=A0so=C2=A0shared=C2=A0in=C2=A0community.=0D=0A=C2=A0=0D=0A>Then=C2=A0u=
se=C2=A0it=C2=A0for=C2=A0internal=C2=A0debugging=C2=A0and=C2=A0provide=C2=
=A0a=C2=A0code=C2=A0which=C2=A0would=C2=A0scale=0D=0A>better=C2=A0on=C2=A0s=
maller=C2=A0systems.=C2=A0We=C2=A0do=C2=A0not=C2=A0need=C2=A0this=C2=A0in=
=C2=A0the=C2=A0kernel=C2=A0IMHO.=C2=A0We=C2=A0do=0D=0A>not=C2=A0merge=C2=A0=
all=C2=A0the=C2=A0debugging=C2=A0patches=C2=A0we=C2=A0use=C2=A0for=C2=A0int=
ernal=C2=A0development.=0D=0A=60=C2=A0=0D=0ANot=20just=20debugging=20but=20=
this=20information=20can=20also=20be=20used=20to=20profile=20and=20tune=20s=
tack=20depot.=20=0D=0AGetting=20count=20of=20stack=20entries=20would=20help=
=20in=20deciding=20hash=20table=20size=20and=20=0D=0Apage=20order=20used=20=
by=20stackdepot.=20=0D=0A=0D=0AFor=20less=20entries,=20bigger=20hash=20tabl=
e=20and=20higher=20page=20order=20slabs=20might=20not=20be=20required=20as=
=20=0D=0Amaintained=20by=20stackdepot.=20As=20i=20already=20mentioned=20sma=
ller=20size=20hashtable=20can=20be=20choosen=20and=20=0D=0Asimilarly=20lowe=
r=20order=20=20pages=20can=20be=20used=20for=20slabs.=0D=0A=0D=0AIf=20you=
=20think=20its=20useful,=20we=20can=20share=20scalable=20patch=20to=20confi=
gure=20below=20two=20values=20based=20on=20=0D=0Anumber=20of=20stack=20entr=
ies=20dynamically.=0D=0A=0D=0A=23define=20STACK_ALLOC_ORDER=202=20=0D=0A=23=
define=20STACK_HASH_SIZE=20(1L=20<<=20STACK_HASH_ORDER)=0D=0A=0D=0A=0D=0ARe=
gards,=0D=0AVaneet=20Narang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

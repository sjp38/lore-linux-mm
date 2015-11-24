Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 945196B0257
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 04:47:36 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so18007006pab.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 01:47:36 -0800 (PST)
Received: from smtprelay.synopsys.com (smtprelay2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id bz5si25457589pab.12.2015.11.24.01.47.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 01:47:35 -0800 (PST)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: + arc-convert-to-dma_map_ops.patch added to -mm tree
Date: Tue, 24 Nov 2015 09:46:40 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA23075F44D3928@IN01WEMBXA.internal.synopsys.com>
References: <564b9e3a.DaXj5xWV8Mzu1fPX%akpm@linux-foundation.org>
 <C2D7FE5348E1B147BCA15975FBA23075F44D2EEF@IN01WEMBXA.internal.synopsys.com>
 <20151124075047.GA29572@lst.de>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "hch@lst.de" <hch@lst.de>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, arcml <linux-snps-arc@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, linux-next <linux-next@vger.kernel.org>, Anton Kolesov <Anton.Kolesov@synopsys.com>, Michael Ellerman <michael@ellerman.id.au>, Stephen Rothwell <sfr@canb.auug.org.au>, Guenter Roeck <linux@roeck-us.net>

On Tuesday 24 November 2015 01:20 PM, hch@lst.de wrote:=0A=
> Hi Vineet,=0A=
>=0A=
> the original version went through the buildbot, which succeeded.  It seem=
s=0A=
> like the official buildbot does not support arc, and might benefit from=
=0A=
> helping to set up an arc environment. =0A=
=0A=
I have in the past asked kisskb service folks - but haven't heard back from=
 them.=0A=
Stephan, Michael could you please add ARC toolchain to kisskb build service=
. I can=0A=
buy you guys a beer (or some other beverage of choice) next time we meet :-=
)=0A=
=0A=
>  However in the meantime Guenther=0A=
> send me output from his buildbot and I sent a fix for arc.=0A=
=0A=
Ok - perhaps Guenter didn't CC me and hence I didn't see you fix.=0A=
=0A=
Thx for doing this series BTW, I was meaning to do this myself as some cust=
omers=0A=
asked for using dma_attr_t etc for their upcoming platform.=0A=
=0A=
-Vineet=0A=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

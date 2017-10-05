Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 701546B0033
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 19:49:26 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id i195so31750667pgd.2
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 16:49:26 -0700 (PDT)
Received: from relmlie2.idc.renesas.com (relmlor3.renesas.com. [210.160.252.173])
        by mx.google.com with ESMTP id 3si151139plp.335.2017.10.05.16.49.24
        for <linux-mm@kvack.org>;
        Thu, 05 Oct 2017 16:49:25 -0700 (PDT)
From: Chris Brandt <Chris.Brandt@renesas.com>
Subject: RE: [PATCH v4 4/5] cramfs: add mmap support
Date: Thu, 5 Oct 2017 23:49:20 +0000
Message-ID: <SG2PR06MB1165A0C7FA2194F1E6013F6B8A700@SG2PR06MB1165.apcprd06.prod.outlook.com>
References: <20170927233224.31676-1-nicolas.pitre@linaro.org>
 <20170927233224.31676-5-nicolas.pitre@linaro.org>
 <20171001083052.GB17116@infradead.org>
 <nycvar.YSQ.7.76.1710011805070.5407@knanqh.ubzr>
 <CAFLxGvzfQrvU-8w7F26mez6fCQD+iS_qRJpLSU+2DniEGouEfA@mail.gmail.com>
 <nycvar.YSQ.7.76.1710021931270.5407@knanqh.ubzr>
 <20171003145732.GA8890@infradead.org>
 <nycvar.YSQ.7.76.1710031107290.5407@knanqh.ubzr>
 <20171003153659.GA31600@infradead.org>
 <nycvar.YSQ.7.76.1710031137580.5407@knanqh.ubzr>
 <20171004072553.GA24620@infradead.org>
 <nycvar.YSQ.7.76.1710041608460.1693@knanqh.ubzr>
 <SG2PR06MB11655D2F14AC44BA565848788A700@SG2PR06MB1165.apcprd06.prod.outlook.com>
 <nycvar.YSQ.7.76.1710051707540.1693@knanqh.ubzr>
In-Reply-To: <nycvar.YSQ.7.76.1710051707540.1693@knanqh.ubzr>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Cc: Christoph Hellwig <hch@infradead.org>, Richard Weinberger <richard.weinberger@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-embedded@vger.kernel.org" <linux-embedded@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Thursday, October 05, 2017, Nicolas Pitre wrote:
> Do you have the same amount of free memory once booted in both cases?

Yes, almost exactly the same, so obvious it must be working the same for
both cases. That's enough evidence for me.

Thanks.

Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

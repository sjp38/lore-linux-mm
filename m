Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 5C0CC6B00DC
	for <linux-mm@kvack.org>; Wed, 23 Oct 2013 07:52:27 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so1064990pab.12
        for <linux-mm@kvack.org>; Wed, 23 Oct 2013 04:52:27 -0700 (PDT)
Received: from psmtp.com ([74.125.245.133])
        by mx.google.com with SMTP id gl1si15200589pac.285.2013.10.23.04.52.25
        for <linux-mm@kvack.org>;
        Wed, 23 Oct 2013 04:52:26 -0700 (PDT)
From: "Bobniev, Roman" <Roman.Bobniev@sonymobile.com>
Date: Wed, 23 Oct 2013 13:52:19 +0200
Subject: RE: [PATCH] slub: proper kmemleak tracking if CONFIG_SLUB_DEBUG
 disabled
Message-ID: <F901C6708ADD5241BD39AFE3DD266906013746E21BDC@seldmbx01.corpusers.net>
References: <1381273137-14680-1-git-send-email-tim.bird@sonymobile.com>,<000001419e9e3e33-67807dca-e435-43ee-88bc-3ead54a83762-000000@email.amazonses.com>
In-Reply-To: <000001419e9e3e33-67807dca-e435-43ee-88bc-3ead54a83762-000000@email.amazonses.com>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "frowand.list@gmail.com" <frowand.list@gmail.com>, =?iso-8859-1?Q?=22Andersson=2C_Bj=F6rn=22?= <Bjorn.Andersson@sonymobile.com>, "tbird20d@gmail.com" <tbird20d@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, "Bird,
 Tim" <Tim.Bird@sonymobile.com>, "cl@linux.com" <cl@linux.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

> On Tue, 8 Oct 2013, Tim Bird wrote:
>=20
> > It also fixes a bug where kmemleak was only partially enabled in some
> > configurations.
>=20
> Acked-by: Christoph Lameter <cl@linux.com>

Could you help me, who the maintainer is that
puts this patch in a tree and pushes it to mainline?
Do we wait on some additional Ack from someone?

With best regards,
Roman.=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id B38208E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 10:04:33 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id y74so818313wmc.0
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 07:04:33 -0800 (PST)
Received: from mo6-p01-ob.smtp.rzone.de (mo6-p01-ob.smtp.rzone.de. [2a01:238:20a:202:5301::9])
        by mx.google.com with ESMTPS id l9si2324588wro.436.2018.12.07.07.04.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Dec 2018 07:04:32 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH 01/34] powerpc: use mm zones more sensibly
From: Christian Zigotzky <chzigotzky@xenosoft.de>
In-Reply-To: <20181207140910.GA23609@lst.de>
Date: Fri, 7 Dec 2018 16:04:16 +0100
Content-Transfer-Encoding: quoted-printable
Message-Id: <037E87F4-38C7-4E5F-A132-B7BB30E3D69D@xenosoft.de>
References: <20181114082314.8965-1-hch@lst.de> <20181114082314.8965-2-hch@lst.de> <20181206140948.GB29741@infradead.org> <87sgz9jzsl.fsf@concordia.ellerman.id.au> <20181207140910.GA23609@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Michael Ellerman <mpe@ellerman.id.au>, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org

I will work at the weekend to figure out where the problematic commit is.

=E2=80=94 Christian

Sent from my iPhone

> On 7. Dec 2018, at 15:09, Christoph Hellwig <hch@lst.de> wrote:
>=20
>> On Fri, Dec 07, 2018 at 11:18:18PM +1100, Michael Ellerman wrote:
>> Christoph Hellwig <hch@infradead.org> writes:
>>=20
>>> Ben / Michael,
>>>=20
>>> can we get this one queued up for 4.21 to prepare for the DMA work later=

>>> on?
>>=20
>> I was hoping the PASEMI / NXP regressions could be solved before
>> merging.
>>=20
>> My p5020ds is booting fine with this series, so I'm not sure why it's
>> causing problems on Christian's machine.
>>=20
>> The last time I turned on my PASEMI board it tripped some breakers, so I
>> need to investigate that before I can help test that.
>>=20
>> I'll see how things look on Monday and either merge the commits you
>> identified or the whole series depending on if there's any more info
>> from Christian.
>=20
> Christian just confirmed everything up to at least
> "powerpc/dma: stop overriding dma_get_required_mask" works for his
> setups.

Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26CD1C4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 04:31:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D6C4A21850
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 04:31:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=googlemail.com header.i=@googlemail.com header.b="rcG/Bw3V"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6C4A21850
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=googlemail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 637FB6B0006; Fri,  5 Apr 2019 00:31:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E6316B000D; Fri,  5 Apr 2019 00:31:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D5466B000E; Fri,  5 Apr 2019 00:31:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 22E4E6B0006
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 00:31:04 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id c21so2221103oig.20
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 21:31:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=+7lBtA8vKkwjwj7PTowhExzIEuTQG9ZRxuYeTf2eq3c=;
        b=LB6R3CgZN/xNQTymCcL03UCaofo6C1E6WBetOhOcEg7duLUXOtqYOavM5z/5eN3aTo
         NjFO9/dNNnLcGzbDL/PzYkQv0t7sMFPsPFUucBclSjZMQr3pzD7zVnYUVneYV1mOJK9q
         wyBVzBmueZthfiYyuXs9LwOUqOb0Y+1TJUkovs4vI/a8b7h/5Vq9wDBltwgf9GpGzi2Y
         Fi+CFLgF+KZ56wYRidrLR8WK0+vXX9zco15QWt4Zu+UkCGi5rjpN4dOwY1fGPUtUGig4
         BvapMulIey1tGVlMv40K4AlSm7Og0mI51PnTbyhEbdAxVcHYDhfRockvY/6b4rUMdl4J
         bp9Q==
X-Gm-Message-State: APjAAAX1MEna8U8S1EuY+K6c+7j2BD8Qs8p72dchLmHEIvuaeYsBiHOM
	3OnJZCA5Zbh97ful7UvFtnfgObSmA9DEwQhYnZeXa50C+QzVxl3WOMyLUqTRQqkMTqecY3OJLkk
	CgctvyzsGfW/Zb/6PAcUps7InMQaAIMWIMJdp1q9Y2MmlPEnbxewai5AQae/no+kWgg==
X-Received: by 2002:a9d:7088:: with SMTP id l8mr7227924otj.312.1554438663808;
        Thu, 04 Apr 2019 21:31:03 -0700 (PDT)
X-Received: by 2002:a9d:7088:: with SMTP id l8mr7227881otj.312.1554438663101;
        Thu, 04 Apr 2019 21:31:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554438663; cv=none;
        d=google.com; s=arc-20160816;
        b=RVuUiVnQySoMmTxTRtIad47iwABNbGiw//FuS8iLRoyVEz48oI8wtfFi4TsmRDjoYR
         hHI0/yAnQEmIRMg/dQo3PvhDP+f6WZvBPrzjaceOCfIvfjQF+Ezkyjl2EDOKoxYeUcLQ
         3bnQXy+fLbwrkE/IHLck+3r0/V5LVI64Pr8LDxPpnZwMaOqgBwWUC9PaGil43GYZespI
         8BSxPm5QTeERg/ffo6yPPidFbisXgysl27Etgpz0uQNlkfmknMSNjPQbkcDLR3Uzt/NQ
         JwbPqDpavsTBjEGJmCpKZxudCI3zeXCvvilj+hdCgGIlt27jqaujCA8F+HPThJhnSgi/
         DeJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=+7lBtA8vKkwjwj7PTowhExzIEuTQG9ZRxuYeTf2eq3c=;
        b=fyr6wK9eMv5Eykq1sCNECsFHtXYiy0xjsFyvQjJHyihQBg6a+LhUKL8wcq1P5R/U6i
         mwqgAAlMCiL5mQFtntMbA6m6kl72AHxfpJUIDUMA9vu9R6WxIOphGhIv4eU/m/tg7qos
         x1aiYPuJzvLC0bdz5/dVDWIxlKCTYOxcMcb5aQyl0wQB8a8W7Hynif+buFvFlVcGdUMz
         azX2r+eOza9REJyr7qNEfDvKlAG17RaCnDnN+HPh6gx4FOai2yNQNYxyP0jgnfwAymu6
         4td3aof6O4psq1r6qvXeTc/2RyYbl72fyRT2T4LykZOLQGPAvy+K38p6GXYHyAmOgF62
         8g6w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@googlemail.com header.s=20161025 header.b="rcG/Bw3V";
       spf=pass (google.com: domain of martin.blumenstingl@googlemail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=martin.blumenstingl@googlemail.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=googlemail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r21sor13365594otk.151.2019.04.04.21.31.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Apr 2019 21:31:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of martin.blumenstingl@googlemail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@googlemail.com header.s=20161025 header.b="rcG/Bw3V";
       spf=pass (google.com: domain of martin.blumenstingl@googlemail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=martin.blumenstingl@googlemail.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=googlemail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=googlemail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=+7lBtA8vKkwjwj7PTowhExzIEuTQG9ZRxuYeTf2eq3c=;
        b=rcG/Bw3Vg4FKUUKeWMIhWWl+Dot5HReKA20TPVY5QGg0EZEWRVdHuNhLlde7bDr2LC
         4BLBBvJSbBRGJmPDGv/B6B0rJypBhrdF5rRlIxvZXGI6AyaQV/QvN2X9FZAL4uqIxvFF
         miIIBZxbDgDNVzJ/lGJ/EBoek9bgSj4A1HSOtmQfmLnXEmanh30ShC/bY2ZcyriSLwpm
         HJ17qsUzqkpKAVjuE32VzvhlvR+54/yQxLNHib6tk3DOBIMIqtcnyY2m1gL/JdQOi1/R
         QxeG6Bf9FzsGG4r4TRGLWd5iqlCDZx90ws5uYaxpFB3/w+torG7AzrLAig+aSkflXOjg
         WPOQ==
X-Google-Smtp-Source: APXvYqwxFoWU7xp487Ebvt3wzo5VYHnSYc2CvTe5RZAI/ctb22VitfNeaCIFtIGcIC9xMiHlKjZ8oQ+fxNcB9ZMAh5k=
X-Received: by 2002:a9d:7856:: with SMTP id c22mr6972611otm.261.1554438662631;
 Thu, 04 Apr 2019 21:31:02 -0700 (PDT)
MIME-Version: 1.0
References: <CAFBinCBOX8HyY-UocsVQvsnTr4XWXyE9oU+f2xhO1=JU0i_9ow@mail.gmail.com>
 <20190321214401.GC19508@bombadil.infradead.org> <CAFBinCA6oK5UhDAt9kva5qRisxr2gxMF26AMK8vC4b1DN5RXrw@mail.gmail.com>
 <5cad2529-8776-687e-58d0-4fb9e2ec59b1@amlogic.com> <CAFBinCA=0XSSVmzfTgb4eSiVFr=XRHqLOVFGyK0++XRty6VjnQ@mail.gmail.com>
 <32799846-b8f0-758f-32eb-a9ce435e0b79@amlogic.com> <CAFBinCDHmuNZxuDf3pe2ij6m8aX2fho7L+B9ZMaMOo28tPZ62Q@mail.gmail.com>
 <79b81748-8508-414f-c08a-c99cb4ae4b2a@amlogic.com>
In-Reply-To: <79b81748-8508-414f-c08a-c99cb4ae4b2a@amlogic.com>
From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Date: Fri, 5 Apr 2019 06:30:51 +0200
Message-ID: <CAFBinCCSkVGp_iWKf=o=7UGuDUWxyLPGdrqGy_P-HPuEJiU1zQ@mail.gmail.com>
Subject: Re: 32-bit Amlogic (ARM) SoC: kernel BUG in kfree()
To: Liang Yang <liang.yang@amlogic.com>
Cc: Matthew Wilcox <willy@infradead.org>, mhocko@suse.com, linux@armlinux.org.uk, 
	linux-kernel@vger.kernel.org, rppt@linux.ibm.com, linux-mm@kvack.org, 
	linux-mtd@lists.infradead.org, linux-amlogic@lists.infradead.org, 
	akpm@linux-foundation.org, linux-arm-kernel@lists.infradead.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Liang,

On Fri, Mar 29, 2019 at 8:44 AM Liang Yang <liang.yang@amlogic.com> wrote:
>
> Hi Martin,
>
> On 2019/3/29 2:03, Martin Blumenstingl wrote:
> > Hi Liang,
> [......]
> >> I don't think it is caused by a different NAND type, but i have followed
> >> the some test on my GXL platform. we can see the result from the
> >> attachment. By the way, i don't find any information about this on meson
> >> NFC datasheet, so i will ask our VLSI.
> >> Martin, May you reproduce it with the new patch on meson8b platform ? I
> >> need a more clear and easier compared log like gxl.txt. Thanks.
> > your gxl.txt is great, finally I can also compare my own results with
> > something that works for you!
> > in my results (see attachment) the "DATA_IN  [256 B, force 8-bit]"
> > instructions result in a different info buffer output.
> > does this make any sense to you?
> >
> I have asked our VLSI designer for explanation or simulation result by
> an e-mail. Thanks.
do you have any update on this?


Martin


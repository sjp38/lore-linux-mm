Return-Path: <SRS0=GuKW=WG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DD7AC32751
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 19:36:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E2C5F20B7C
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 19:36:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oj+5pLDd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E2C5F20B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 68C9E6B0003; Sat, 10 Aug 2019 15:36:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63DD96B0005; Sat, 10 Aug 2019 15:36:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5074A6B0006; Sat, 10 Aug 2019 15:36:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 24C9F6B0003
	for <linux-mm@kvack.org>; Sat, 10 Aug 2019 15:36:39 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id t26so5813288otm.9
        for <linux-mm@kvack.org>; Sat, 10 Aug 2019 12:36:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=o3yb3LBkgCj2WvJ0+Uh/BuPywJFT4H1nD+b3TdWQhSU=;
        b=iPglE5Lyd+b/SpiCWZMONvrhWpQPvuHugVbudI/DZl6Dm/cRwdxs8lNk1ip/8ATH6+
         G31x3c6PG3QWILoT21loCddn0TQvV0P+QcThWc6t9EwN2i0emTmH+UylGZs5nc8qECXl
         wR+xlZQmw4AhKoc+MOWQUOX9hk5wVjU6t7Y/4i9+cz9vUfv3q0EtuPjCfllbRkm5qnnR
         guW3g7EENaeiK19xbyrb4RRqVTJAAulm9e4//zk49yZDK2IWbzjy+pqtwRlLb8UMeXYe
         YdVPC4f1xVkv1tBV754THQe7XpnI5szCWfR06vhDcZ9BLxQi51k4oR7vYnl6W2bcYwKG
         EqbA==
X-Gm-Message-State: APjAAAUBoggkJrSXjmW+lkzDbXIptLEFVVQtRA5d35Sa9/5qXjtdpixV
	LtLte/Oq34K2ilVUN8Lht42cAj04rfphrtwB5GAdi6V/d2Av9PQtxfeNcRCCk374Bf1iHp1ARUE
	VNdF11zSxoGpQNySDmowxf4IPs/a9DeW9czNR80TMnRpp+mX/AqWYNDgQ3AYEkgsW6A==
X-Received: by 2002:a05:6830:2090:: with SMTP id y16mr22288974otq.109.1565465798895;
        Sat, 10 Aug 2019 12:36:38 -0700 (PDT)
X-Received: by 2002:a05:6830:2090:: with SMTP id y16mr22288958otq.109.1565465798294;
        Sat, 10 Aug 2019 12:36:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565465798; cv=none;
        d=google.com; s=arc-20160816;
        b=Lptu2px8LqM7COTzByT744/x9k4SlmLx86lk9rFlZiwFIH3ppGZQTROJllI0FEaByq
         pWAtq8cE77E77WdOshomgNOd3ovGX2HDPnWs1+HxXRO+9SNKXgi1z9a3i9ldLXW3pgf7
         Kak6DdoVyMUvDhSGqLpcI/u84uiOWeL0v34fhDF8rO64Qzj/46hY6tJDTiWi1BIvJAs5
         jHDTXlqh2MW8/TZ/DwUzyBptaeu+zSxbeO4UKUD5EJ47Q6NqNooRzIcu1yat5F0GB9UK
         QSfZ09UlJLWsTDv9TVFXjxdmSQ5t1/reoDALdQoH+ImUJDrHwbnsu7PZVFoKkIqmeMBf
         j/UQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=o3yb3LBkgCj2WvJ0+Uh/BuPywJFT4H1nD+b3TdWQhSU=;
        b=BcQ9fRvkttwqUoRvkc4r3uTbCdcgJ8ykWMpNNeezD0JubYi4oj5j5gWkRVNxZjUj9Y
         1M+vVSuhUub0UxcdShDRfA/Y1GfLo0cLEncAQ4RRiq4cLFzNW2QFs0WJ7a639jbL+Kpy
         y8qZubWtPBVWcGux/cnnDZ4DpHvixzMqpSmLP2NHxt2tNT6PNO7xR4uOogC84lszUP4F
         eTQjAyOjN5DZ2A7iAjnt2q9WFONgSlWx/mU/9i4JEoUfGDpEa1Gpuim1GbHu3vu/HkQG
         pLIyOs4YpYjjsesK5m/XhJIFXHOr3gy1HSU9hwS2A9PeSduugGJjGinjgxuH33bwuR7Z
         k7FQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oj+5pLDd;
       spf=pass (google.com: domain of mikpelinux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mikpelinux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j26sor46922240oie.35.2019.08.10.12.36.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 10 Aug 2019 12:36:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of mikpelinux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oj+5pLDd;
       spf=pass (google.com: domain of mikpelinux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mikpelinux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=o3yb3LBkgCj2WvJ0+Uh/BuPywJFT4H1nD+b3TdWQhSU=;
        b=oj+5pLDdOrDIiAbaNDjQ1bkeAXV5AjT9TALASs8w5TWKZj3/dFkC2vv5yeQmG2uObR
         nhAVrWZmWM926inhvI08Pacm8FS4B3Sk5foq7dAYZ4S7oI7qkj41d2fGbke6Ad8ALZ4r
         UVQiWi+6+fw3QUqitteCJHBfvzaL/tCc/yTjT2LRHIP9AGgf72OnhYiQ+50XkoCWPIYF
         oS7Of0bG49hQB4RMbZNBZkWUqfIXQQlVj7dGZnpyMZEBJ1UAUAWDXDlbflfQamJwuAni
         saowKPupGI/V/yXVQmRSYuKfixhEyQwsJjr2eLoQgFetB5POTKwMs/cXzJYjnFmuRR7f
         LpSA==
X-Google-Smtp-Source: APXvYqwN+kQL85VSwh3lLWhx/55k2LTWeEHB2UFHSABa5sTDQl+sissp0jrGB1GwrOcENUeIvg/JCdsMYwsmdPxjRGc=
X-Received: by 2002:aca:c588:: with SMTP id v130mr5068345oif.165.1565465797825;
 Sat, 10 Aug 2019 12:36:37 -0700 (PDT)
MIME-Version: 1.0
References: <20190625143715.1689-1-hch@lst.de> <20190625143715.1689-10-hch@lst.de>
 <20190717215956.GA30369@altlinux.org> <CADxRZqy61-JOYSv3xtdeW_wTDqKovqDg2G+a-=LH3w=mrf2zUQ@mail.gmail.com>
 <20190810071701.GA23686@lst.de>
In-Reply-To: <20190810071701.GA23686@lst.de>
From: Mikael Pettersson <mikpelinux@gmail.com>
Date: Sat, 10 Aug 2019 21:36:26 +0200
Message-ID: <CAM43=SNbjVJRZs7r=GqFG0ajOs5wY4pZzr_QfVZinFRWV8ioBg@mail.gmail.com>
Subject: Re: [PATCH 09/16] sparc64: use the generic get_user_pages_fast code
To: Christoph Hellwig <hch@lst.de>
Cc: Anatoly Pugachev <matorola@gmail.com>, "Dmitry V. Levin" <ldv@altlinux.org>, 
	Khalid Aziz <khalid.aziz@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>, 
	Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, 
	Sparc kernel list <sparclinux@vger.kernel.org>, linux-mm@kvack.org, 
	Linux Kernel list <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

For the record the futex test case OOPSes a 5.3-rc3 kernel running on
a Sun Blade 2500 (2 x USIIIi).  This system runs a custom distro with
a custom toolchain (gcc-8.3 based), so I doubt it's a distro problem.

On Sat, Aug 10, 2019 at 9:17 AM Christoph Hellwig <hch@lst.de> wrote:
>
> There isn't really a way to use an arch-specific get_user_pages_fast
> in mainline, you'd need to revert the whole series.  As a relatively
> quick workaround you can just remove the
>
>         select HAVE_FAST_GUP if SPARC64
>
> line from arch/sparc/Kconfig


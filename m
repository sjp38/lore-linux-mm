Return-Path: <SRS0=GxOJ=TZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55028C282CE
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 17:07:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B89320862
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 17:07:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="blWPgG96"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B89320862
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA3626B0007; Sat, 25 May 2019 13:07:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A2D516B0008; Sat, 25 May 2019 13:07:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F4266B000A; Sat, 25 May 2019 13:07:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2A6F56B0007
	for <linux-mm@kvack.org>; Sat, 25 May 2019 13:07:53 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id y11so2390752ljc.20
        for <linux-mm@kvack.org>; Sat, 25 May 2019 10:07:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=G5ktK9kr4E0UpbbeaHLRBxZcSjVJhVPG4g8QF69sVmY=;
        b=Radm+vRxDAyHrdJRRP19Ob3ExkmGmDeDiwnqoiGL3mVG3hQRTuX7JJnZpjEwg3K7BQ
         5c8Vc9mJ1G4HI9bNFwDd1beJB27satWdSdGfbGjOL/hVYLECCt93u2EWx0ks1z+PzfZk
         nWkVv4lwR30XOgOrsq/jXvrVLmXp/1g9EKksSv+tHt2i8AvzqXrmiFfAOgi+1qDp65Gu
         ermhyBux8IM7DeSnEUhq1EG2VYv/weNwFDOZ9croQbEixTrCbURl5sZLUtRRrqc2QS2a
         q2futZU917xm8oXGy+i3mWlLJvztbSg5Xoxha2KtQhMkXqrBYKORhcARRaW4zTESgbAc
         /x9w==
X-Gm-Message-State: APjAAAXq4atQFllb3aMEo0NcXOl96HZ+0eHxOiBLbLAncNg+x7TdKUH9
	XMLwC88TxOykbuDlULrtpJoi6yjx8MSMeIOaO9SB4x0MojO7cBA2on9Ud0fFdTvfpGwXt5xR38x
	K3r3h+tdiqWA3om7KwjXhGgpA4AcUyr3xr5tfzF8vF8dC01Pk+QJkiHfDi2Kjz6Y1dQ==
X-Received: by 2002:a2e:4710:: with SMTP id u16mr26768284lja.41.1558804072537;
        Sat, 25 May 2019 10:07:52 -0700 (PDT)
X-Received: by 2002:a2e:4710:: with SMTP id u16mr26768249lja.41.1558804071673;
        Sat, 25 May 2019 10:07:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558804071; cv=none;
        d=google.com; s=arc-20160816;
        b=OH3akUQbDLz37EZy4qXBAXdFXezrmr3uu2QwPsGMf30jxuFkKPSy9q2NY6Hv2/n960
         fWZnoPQ7Wj13dNRyW/q/3uDG4BYPF3bWe6jCpiA89TTJ5vG35GjpLqoBh5ZjGA/IJx6V
         v/RCnqarf9CciwiCABzCUmdBGviUUMI+98Uk7JLXg/JdBw0OzwFpoY4ROvLifDFx8dVT
         JAzxyyzas46wc1eTS0OWpJpqIcEHv6vb5BHUx4hEvVoauhocqIjp+BtE1KnMN9AiVzIV
         rgQjvg3h4PSQSbNAHE+8Hj8X4HzEiJY5dMymBlIHU/BZjzr5i2yie5Z9YwB7YMIZpa9X
         MJQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=G5ktK9kr4E0UpbbeaHLRBxZcSjVJhVPG4g8QF69sVmY=;
        b=p/9NuW3NygO30vrlHkimDr7KltZ6mJzEXTWJPwpYHJrqlOlAmOu4KpZgUsXK/VeKU5
         tGiKYqb82GX5zqp5nScF7r2TLEwG4ANVLhtXKTr74pL1s6XWpB49fOo35KEW8+9GPjHL
         qDLfeCllFbH506U5RAvQArX/GIsQ+JDoTiHMqeEX9uMvF8/MzWedT4vnRhIeX/KuGOlf
         dhp9TS2AZ13Ma8rWI6w1cIESNSKCVQ0yUssfWtfHSUx2tKoSiqMjiRqYLCeBNxN/7dZ1
         YSTGru6kfCOLpjXAVC/dXUObc+mbo/mV26gaz1xYhPD2+AS/PPAV3eN4ijuEjiS/xRoZ
         R0Kw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=blWPgG96;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w14sor1666493lfe.20.2019.05.25.10.07.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 25 May 2019 10:07:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=blWPgG96;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=G5ktK9kr4E0UpbbeaHLRBxZcSjVJhVPG4g8QF69sVmY=;
        b=blWPgG96+VVQqIzaWJtzwSPl1QZ1S0Z04iNWgu72UYrrEMJjAjb0uL1VklvosGRad1
         QjwqdkB2pvLto1OJmIjJxoAO0TOZpQ+qmzwwgKrs9zICCkP//YwaeBtPKJ0BOb1W3+mo
         iEJkOggeA90YvBtGTsZFgAObtE+OMxPecZ/Qg=
X-Google-Smtp-Source: APXvYqzbJyAt97El2JehH+F0ntl7SFLcChGlsTjfKP8x/VDVTTKsNOBwsvrg2v8dQ8Mse3x9bj8hww==
X-Received: by 2002:a19:e212:: with SMTP id z18mr3109813lfg.192.1558804070788;
        Sat, 25 May 2019 10:07:50 -0700 (PDT)
Received: from mail-lf1-f41.google.com (mail-lf1-f41.google.com. [209.85.167.41])
        by smtp.gmail.com with ESMTPSA id j1sm1193457lja.17.2019.05.25.10.07.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 May 2019 10:07:49 -0700 (PDT)
Received: by mail-lf1-f41.google.com with SMTP id y13so9249975lfh.9
        for <linux-mm@kvack.org>; Sat, 25 May 2019 10:07:48 -0700 (PDT)
X-Received: by 2002:a19:be17:: with SMTP id o23mr28987773lff.170.1558804068519;
 Sat, 25 May 2019 10:07:48 -0700 (PDT)
MIME-Version: 1.0
References: <20190525133203.25853-1-hch@lst.de>
In-Reply-To: <20190525133203.25853-1-hch@lst.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 25 May 2019 10:07:32 -0700
X-Gmail-Original-Message-ID: <CAHk-=wi7=yxWUwao10GfUvE1aecidtHm8TGTPAUnvg0kbH8fpA@mail.gmail.com>
Message-ID: <CAHk-=wi7=yxWUwao10GfUvE1aecidtHm8TGTPAUnvg0kbH8fpA@mail.gmail.com>
Subject: Re: RFC: switch the remaining architectures to use generic GUP
To: Christoph Hellwig <hch@lst.de>
Cc: Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>, 
	Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, 
	"David S. Miller" <davem@davemloft.net>, Nicholas Piggin <npiggin@gmail.com>, linux-mips@vger.kernel.org, 
	Linux-sh list <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org, 
	Linux-MM <linux-mm@kvack.org>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Looks good to me apart from the question about sparc64 (that you also
raised) and requesting that interface to be re-named if it is really
needed.

Let's just do it (but presumably for 5.3), and any architecture that
doesn't react to this and gets broken because it wasn't tested can get
fixed up later when/if they notice.

              Linus


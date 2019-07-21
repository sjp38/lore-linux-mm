Return-Path: <SRS0=x6gJ=VS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9E2EC76196
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 16:53:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 71C2E21721
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 16:53:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="SfsRifqu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71C2E21721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 335FD6B000C; Sun, 21 Jul 2019 12:53:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2BEC46B000D; Sun, 21 Jul 2019 12:53:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 187DB8E0005; Sun, 21 Jul 2019 12:53:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id C10E26B000C
	for <linux-mm@kvack.org>; Sun, 21 Jul 2019 12:53:50 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id o184so3367792lfa.12
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 09:53:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=d5u5pYqXEq+IeJ5qYP8FGZejReb4Nr/dgdEELXviWuQ=;
        b=SEBFuToIV4a/ptTWYXulC+H2MTMINqh4EOiJfzPOoELYSyEqAOLZQTIm9ivM1XcBGn
         /FWD1WmQalTTzEDbH+VVTsRPkZkXvJ3I2u7pV/+k6KvWBbHc4p9D6a+DzToFQOAocxvb
         GGtuZ+Qg/1SSpGob4q0YwPPlGL30ISIT5bpsADVdzsow8Arza2e272q10hfiA1svKGNh
         b0G8JoYdv7CgZ+k1PDhQurNU7jIVt/tfpi50ahyGyZMaatozRbb9LkcdmdZo+nOqxOVo
         ntAu1lYSz4+Womm22QGw+m4QRdKeSI+vazoNztmcUBMEKJj97Bi79+meYxS5hKY65vnu
         aslQ==
X-Gm-Message-State: APjAAAXQJOr2eP2rsonOm+KcCcZ8xyUSCf1jfpwU3HiuoAw2FPCx93sM
	TV9aCpgurAHD7epXlfUW0beWnfgrU98OqWtx/BtVE++1eqxdFlpAJ2k0XHZjXAkEzUBS3AyMmoi
	Afe14qDSY3CZLsFcjb3glHlQuG9SxtYWr8QZ5PQRXkexOIdo+L4lhMopO3NcIhi+pgg==
X-Received: by 2002:ac2:46ef:: with SMTP id q15mr30360755lfo.63.1563728029898;
        Sun, 21 Jul 2019 09:53:49 -0700 (PDT)
X-Received: by 2002:ac2:46ef:: with SMTP id q15mr30360730lfo.63.1563728028988;
        Sun, 21 Jul 2019 09:53:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563728028; cv=none;
        d=google.com; s=arc-20160816;
        b=bUvP/9+EWPgEhnyMEv6zlo/+ekM5BSomiYkyvW1km+5ez7faBTeZftR41QIOUWg3cX
         1t7ECBkCVUfrm1UUk568yMeQ4DR5S4bJ4Qo3AgRD8J8eUwLnp8p20pH6wunprCsWY8Q0
         +gIN/o3mOvZugJ05cHmXTTVZBadIEnqBREYHZq8xFZjvuEtM+A/gUNe7ro5zLxwd37XT
         JUkT+p3T6t79zayRYOsZ8mLF7wI2T7/pvcUb7TOK8/Sx+cOXbdIqL/w0k+AGYQvTXvB+
         i26PwvJFt3ku9Ih939/3n65i0w/0RhHcgn0E78K/iDUXdgtyxMc7G+Lrina82Ph28kpO
         AAhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=d5u5pYqXEq+IeJ5qYP8FGZejReb4Nr/dgdEELXviWuQ=;
        b=VPkniYyYbkZpJXIdEETlwMK2jkVdCaHImsxTMsNAhOXtDloK7hIqANGqbY8MsY9FrX
         EGvSjLaFFjVOSIguMEA+P6P0VWbBu+6XAb5R037/xB/yLces4OCNAZPK5ZyIFiqbXFa+
         cZ+XaJshLmIjnf41qyfQsO9F4bir/Z7zFRJHIu+HrvEpwLN0xNdcXt/lpW02Kzt0mw9y
         SHDGZWMSKMOlPazZxTyZyNnMYkke/V+zb5rku5D00Q4Eb9B4wnL2lqRR5yS2+vqo4bbm
         hbQ5HlVIhFJbuPkBfOLZlgcIPI2Y4dtRZmAEXt0yzj4uXLwCLSPfHZ+5oipoTYT11TF7
         jXug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=SfsRifqu;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p127sor9473512lfa.9.2019.07.21.09.53.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 21 Jul 2019 09:53:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=SfsRifqu;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=d5u5pYqXEq+IeJ5qYP8FGZejReb4Nr/dgdEELXviWuQ=;
        b=SfsRifqu+/ZSthpm4gGscjWytOn4AblnNEKGWQiyBnd3PO0tY2AUD1Dw9bLJkXVq6l
         bi7L001ejkx8PoKwPhLRRscBLevCouzWJTl1UCqvNgOy0GG+3IBFVFZSuRizDg6/6ob+
         yCDdDMR+6ZXuFfvVtmBzj0aLDjFeTHeOeokhY=
X-Google-Smtp-Source: APXvYqw9OM5WZzb/6YTDrLptQvJfOdo0XiIctMersQA0ScNkBkoq2HqbHXyL7cs25l/FANdRFZas2g==
X-Received: by 2002:ac2:5dc3:: with SMTP id x3mr29425690lfq.168.1563728028086;
        Sun, 21 Jul 2019 09:53:48 -0700 (PDT)
Received: from mail-lj1-f175.google.com (mail-lj1-f175.google.com. [209.85.208.175])
        by smtp.gmail.com with ESMTPSA id t21sm5678868lfl.17.2019.07.21.09.53.47
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Jul 2019 09:53:47 -0700 (PDT)
Received: by mail-lj1-f175.google.com with SMTP id x25so35237154ljh.2
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 09:53:47 -0700 (PDT)
X-Received: by 2002:a2e:9192:: with SMTP id f18mr4208181ljg.52.1563728026894;
 Sun, 21 Jul 2019 09:53:46 -0700 (PDT)
MIME-Version: 1.0
References: <20190721141914.GD26312@rapoport-lnx>
In-Reply-To: <20190721141914.GD26312@rapoport-lnx>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 21 Jul 2019 09:53:31 -0700
X-Gmail-Original-Message-ID: <CAHk-=whbd8UWeX-O-Zpn5iKdC6YMxef9UuH3R=TL14W5N86h0g@mail.gmail.com>
Message-ID: <CAHk-=whbd8UWeX-O-Zpn5iKdC6YMxef9UuH3R=TL14W5N86h0g@mail.gmail.com>
Subject: Re: [RESEND PATCH v2 06/14] hexagon: switch to generic version of pte allocation
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Richard Kuo <rkuo@codeaurora.org>, 
	linux-hexagon@vger.kernel.org, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 21, 2019 at 7:19 AM Mike Rapoport <rppt@linux.ibm.com> wrote:
>
> I understand that merge window is going to close in couple of hours, but
> maybe this may still go in?

Applied.

              Linus


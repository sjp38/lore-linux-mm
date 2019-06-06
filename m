Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9FB2C46470
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 22:45:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C6D320868
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 22:45:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="SIE+1nvW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C6D320868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36DB46B02FC; Thu,  6 Jun 2019 18:45:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31DF76B02FE; Thu,  6 Jun 2019 18:45:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20C9F6B02FF; Thu,  6 Jun 2019 18:45:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id DD5636B02FC
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 18:45:11 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id b24so89621plz.20
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 15:45:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=HACnMQtPYnOPzs/mDwm4zputQD0bQTBQV8IWL1Bp2bk=;
        b=S8avD38jP9EmTB7YbAVRf4DqHYGum/QFntPt5DDdnLMPv401HnA9uceLBWZb/Qt6PX
         PPG14O0EpkwcpdRKZuamUT9N4lRLhDSSH1psni38NdGahqqT0hxIDaf1w9ZW1c3YcO6t
         5YVPa+azxxT/NTmrYtDG/5wjJhxrkbtOpdA7+kbF4I/xEKxN09nXxi4YdqLBFz7/LWIL
         CHNSoy3aRBSv3mIOMOvBuFEdfdan5jWRnQPfunV2LYB7+TDQkoEyqOxyp16VKkNRWe6p
         GWgPbtMrxEPQlk46JfY6MPu0sTyjrg7WFb1p+5b7FX9s8+jkRIPm6vlCtznuDtLDvYDN
         t+PQ==
X-Gm-Message-State: APjAAAXICrtTQrxLM4mfs+CAlvLsb2SlfmPVxf97ScVKJPWcUQS621Y/
	CN4cE8ee7foK4a/bYncAYJcbFnJw8ZkpBsb1ifIzM1jKGO8X42QXatStAMZKiXZvpwjwexTT6IV
	o6bsL37hYVj1DSMvAFcooMN4dcM0sKaTarqu4Jx2Nobznkrw/MAurzfFyqe8Mtk3UaQ==
X-Received: by 2002:aa7:9aaf:: with SMTP id x15mr3229291pfi.214.1559861111327;
        Thu, 06 Jun 2019 15:45:11 -0700 (PDT)
X-Received: by 2002:aa7:9aaf:: with SMTP id x15mr3229240pfi.214.1559861110684;
        Thu, 06 Jun 2019 15:45:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559861110; cv=none;
        d=google.com; s=arc-20160816;
        b=NgJuGleH9LomK6IjeHRAahbjtEj2qtLCeSz/nxKxsMeUFVYtHY+DwwrGBFFkRIG6+t
         TXvn3dgXngVcFjJLzhjNof3bbOlWHWlq5CW8n7dtzDRcvU8jcwov+wiW4bCBQzmtIATD
         2P1xeXq1dx9uzD5k6EhqH3G48og/DFbkIp6wZvNH+IC+a8dlc1Y7Lzwmq22oHe/90/b0
         LyQlxHCIAFLmgfoqS4Aks8QcaXFuFehbqfdOrbygTFTLNXAQCDO4MYrvXnZkE3yCtMa3
         j1DmhbWK3Q+lyLeTo52q8nxGOfsqsTzpXUC6cwK08rV4O6h9XHcAT+JykUJkZVjcFAwx
         Eeaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=HACnMQtPYnOPzs/mDwm4zputQD0bQTBQV8IWL1Bp2bk=;
        b=nUkPuJmF4VjrPGo3pNHSAHwXQo39HvfqgaxWO0N+tRBIykl23sGklZBFJ9d3lRyeNN
         6C1++7qgRi0fl9RuVvj7d5jM6W3ZnHXgv71J+ZqvgTHg992OaPzLOsTaAg55On4aAcnB
         qg82ygt1KDGzvcoPtpy3p+wHy0t3OM1EFXMKRouX/cwLoQxHzep6nLhbY3T9AILxZNqR
         arsWtyAGJGpnC5B0WznxjHAkrz3P60IMk8NFead1DnNZIuthaVDyBF0qHUN3Nqdr5Q15
         akbXgZgpWi64gEV2ZV+fRWyi2nw107u+Pr6orZjW3U/KASI/YNYw3Ks0Zh/FRap/G0Po
         ZHTw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=SIE+1nvW;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m13sor330571pff.45.2019.06.06.15.45.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 15:45:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=SIE+1nvW;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=HACnMQtPYnOPzs/mDwm4zputQD0bQTBQV8IWL1Bp2bk=;
        b=SIE+1nvWpCuuB8LQr4c2J5pdl9aN9TrZOuogqp0LuJdSCuJ7s3L/mwrQsN757QZwkL
         31MRdfiC4VlGxER8Nbk3eoehRYG45TPv0X47fAaLSi8NckGV2eY2Jwrt8KamFonbvefW
         JQuAMfCV3DzEvIW2EBETktFuUGqPf+Hg1Rip0=
X-Google-Smtp-Source: APXvYqzogBbs8NWhvAy6+K9bKGJowUgCD2OgwqNEA9Uv5xkcveaCMWVLXrYham6bjQifkgDDCXFp3w==
X-Received: by 2002:a62:6143:: with SMTP id v64mr18839097pfb.42.1559861110305;
        Thu, 06 Jun 2019 15:45:10 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id v9sm184849pfm.34.2019.06.06.15.45.09
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Jun 2019 15:45:09 -0700 (PDT)
Date: Thu, 6 Jun 2019 15:45:08 -0700
From: Kees Cook <keescook@chromium.org>
To: Matthew Garrett <mjg59@google.com>
Cc: Linux-MM <linux-mm@kvack.org>, Matthew Wilcox <willy@infradead.org>,
	Alexander Potapenko <glider@google.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH V4] mm: Allow userland to request that the kernel clear
 memory on release
Message-ID: <201906061543.10940C6@keescook>
References: <CACdnJuup-y1xAO93wr+nr6ARacxJ9YXgaceQK9TLktE7shab1w@mail.gmail.com>
 <20190429193631.119828-1-matthewgarrett@google.com>
 <CACdnJuvJcJ4Rkp7gBTwZ_r_9wKtu34Yko+E3yo07cwc53QrGGA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACdnJuvJcJ4Rkp7gBTwZ_r_9wKtu34Yko+E3yo07cwc53QrGGA@mail.gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 05, 2019 at 11:26:03AM -0700, Matthew Garrett wrote:
> Any further feedback on this? Does it seem conceptually useful?

Hi!

I love this patch, and I think it can nicely combine with Alexander's
init_on_alloc/free series[1].

One thing I'd like to see changed is that the DONTWIPE call should
wipe the memory. That way, there is no need to "trust" child behavior.
The only way out of the WIPE flag is that the memory gets wiped.

[1] https://patchwork.kernel.org/patch/10967023/

-- 
Kees Cook


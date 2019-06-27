Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9FA9BC48BD9
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 16:44:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A63B2147A
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 16:44:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="geImDuUK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A63B2147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D8BE16B0003; Thu, 27 Jun 2019 12:44:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D3DCC8E0003; Thu, 27 Jun 2019 12:44:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C05A18E0002; Thu, 27 Jun 2019 12:44:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9F7C76B0003
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 12:44:08 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id y19so3021433qtm.0
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 09:44:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=w2BmOlVfFwkgLZSQC1w8R20Owu5XUJlV/BzLLVY15k0=;
        b=AoG9ks5sntIwdqiMz7Ztl0vN05CCDvE2rVii8/jO/venLsCtryMf4oUMPQA8bfHOEX
         qnAgkp43WusXbcap8jgIxZ5ofbpraIZJ/+hxP9p+MTl3gwZ7Osmmtj5SpvVZ8D8r3L+m
         h2ft+Z7th57pTw3/pVz2cdQfHKAy5Nt7ZXSLPb0woVA1biKRMyIvM3Kfq/1DPSCIOtGb
         zp7VUWAzhujhEx0iiOgRmLnOIk3ekwyYalB8pK0LUB8U0OEVkKgHYL9Q3v+g1hEYEzVg
         IXKJdvP6ybH49fhfWHoZmz1zg/zF8xkqKb1cRxjGWV7CSHQbk9i3urqD2XsxwJYw8RaL
         2Qog==
X-Gm-Message-State: APjAAAVCgvyg26neEHknUc1KtIIKzi2yMriRSc7Y+R2BmMT1dbD6fSTz
	4DJJMqUQ878vIKtvczOwHBmRJgvkURt6l8tWk0sCVK5KMi8yIurwUGRjL1BLthNyx2vI+kV1jgI
	R+mjEu/6GSkUqd/aqIuVBVACGP3mMBA16I/1rQHEj1Lc6c4Z30T41m1I64WZWuRYclg==
X-Received: by 2002:a37:98c3:: with SMTP id a186mr4375910qke.498.1561653848393;
        Thu, 27 Jun 2019 09:44:08 -0700 (PDT)
X-Received: by 2002:a37:98c3:: with SMTP id a186mr4375866qke.498.1561653847838;
        Thu, 27 Jun 2019 09:44:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561653847; cv=none;
        d=google.com; s=arc-20160816;
        b=iCj0eSQWpxZ3+97gqaYUV6RNUXl57oCTECIPuafw/9GnVCc6BunCaHp5mCNYPggLIq
         p6qVgUCtA8EJ1HfLFc1I5xue8x8zD8p7Km/Y+18PtUbsoZHC/R21QKb/l7Xi3lqZy8xM
         Rl0UAY4eNsF752gzHV17YWHc5RiQNtdlvk6oLHNZZG7oy2Ao7KtoFlvu9g9idxhpEsGQ
         /iJObjDA/8tZNZyKHLg9crOT9/XCLEVvQyYMRt5Dpi/Ns6Lnt0hnE72IO4hhaZJfsKGP
         hhDnxPWaFf25oTW5qx+sVtU5QApyuyEfzYxYDb6cvJQ4dSjJd4WnctntlUDoipX1hNWI
         jnhQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=w2BmOlVfFwkgLZSQC1w8R20Owu5XUJlV/BzLLVY15k0=;
        b=adqS9M0913IbXDSZ0F8RSv0P3Vc8h4FOsHzcYtXUxVTEff4dr9+bNcKvLUiSO7jdf3
         fCkaV3x0htcM+iPOkue0Epd6fmKi7NVe7hGZTrlX41gN4eIdq2RSTMosQ0e1x3GyUHOC
         XQ7Dd1vjuyIGmRB6UiqVVEDlb93Kt5NIX5GuVahzpt+undN0CbMM7oaiaNOe8C2kwnRU
         XDFM3bMcAhbuj7SZt2H4utXKXeQraYJu53s8IyyLJow4DJ009+yKh8Kn5/FAzWIaOaHY
         CAfH/+H6cM0hm3L33kjNYOM5ddJn9eOhkqoEcFPEN7/eaNUjs03oRKSaMM7t0VHSd/X+
         4qKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=geImDuUK;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i6sor1767647qkc.47.2019.06.27.09.44.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 09:44:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=geImDuUK;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=w2BmOlVfFwkgLZSQC1w8R20Owu5XUJlV/BzLLVY15k0=;
        b=geImDuUK3nzgaKe4rg1kDwEEwfUdwvxURv/YU09DF9oFlWMFeIGMHkNFo+kl+Mvfgp
         3NO8fx+rX1WWjRagnKQMMJXa7pZt+GIeetEEtjHApswcGjlKc+gxyDCKrAzKCe62curu
         iW3bdzqK2OkSXzpeeJRpbwoTJgCh3u5Amano2cgvcnouqqXbiCvwAk366bvP8GkEgKAY
         1XYyATJFDwDk7/D++da1v3yBiCjkjfVbCeUbPEqBas4q+imDOQ1Gp08PVnQ835YTl4e3
         KVWwxlF+N5UDMQYpCb+jztRgrugr2eMpS3t4p9tRj4wNkE5ZVAADfT74LIah+lTkfQlG
         fWcA==
X-Google-Smtp-Source: APXvYqy634RuieC+fz/WCPxqpxiLBIdyBILOYC+PwsQcQ+t7LBPTDYlzrhZfeWGzOYF9AbMHbkQZYQ==
X-Received: by 2002:a37:5d07:: with SMTP id r7mr4294931qkb.4.1561653847500;
        Thu, 27 Jun 2019 09:44:07 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id f3sm1180627qkb.58.2019.06.27.09.44.05
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 09:44:06 -0700 (PDT)
Message-ID: <1561653844.5154.87.camel@lca.pw>
Subject: Re: [PATCH v9 1/2] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
From: Qian Cai <cai@lca.pw>
To: Kees Cook <keescook@chromium.org>
Cc: Alexander Potapenko <glider@google.com>, Andrew Morton
 <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Masahiro
 Yamada <yamada.masahiro@socionext.com>, Michal Hocko <mhocko@kernel.org>,
 James Morris <jmorris@namei.org>, "Serge E. Hallyn" <serge@hallyn.com>,
 Nick Desaulniers <ndesaulniers@google.com>, Kostya Serebryany
 <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Sandeep Patil
 <sspatil@android.com>, Laura Abbott <labbott@redhat.com>, Randy Dunlap
 <rdunlap@infradead.org>, Jann Horn <jannh@google.com>, Mark Rutland
 <mark.rutland@arm.com>, Marco Elver <elver@google.com>, linux-mm@kvack.org,
 linux-security-module@vger.kernel.org,  kernel-hardening@lists.openwall.com
Date: Thu, 27 Jun 2019 12:44:04 -0400
In-Reply-To: <201906270926.02AAEE93@keescook>
References: <20190627130316.254309-1-glider@google.com>
	 <20190627130316.254309-2-glider@google.com>
	 <1561641911.5154.85.camel@lca.pw> <201906270926.02AAEE93@keescook>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-06-27 at 09:29 -0700, Kees Cook wrote:
> On Thu, Jun 27, 2019 at 09:25:11AM -0400, Qian Cai wrote:
> > On Thu, 2019-06-27 at 15:03 +0200, Alexander Potapenko wrote:
> > > +static int __init early_init_on_alloc(char *buf)
> > > +{
> > > +	int ret;
> > > +	bool bool_result;
> > > +
> > > +	if (!buf)
> > > +		return -EINVAL;
> > > +	ret = kstrtobool(buf, &bool_result);
> > > +	if (bool_result && IS_ENABLED(CONFIG_PAGE_POISONING))
> > > +		pr_warn("mem auto-init: CONFIG_PAGE_POISONING is on, will
> > > take precedence over init_on_alloc\n");
> > 
> > I don't like the warning here. It makes people think it is bug that need to
> > be
> > fixed, but actually it is just information. People could enable both in a
> > debug
> > kernel.
> 
> How would you suggest it be adjusted? Should it be silent, or be
> switched to pr_info()?

pr_info() sounds more reasonable to me, so people don't need to guess the
correct behavior. Ideally, CONFIG_PAGE_POISONING should be  renamed to something
like CONFIG_INIT_ON_FREE_CHECK, and it only does the checking part if enabled,
and init_on_free will gain an ability to poison a pattern other than 0.

Also, there might be some rooms to consolidate with SLAB_POSION as well.

> 
> Also, doesn't this need to check "want_page_poisoning", not just
> CONFIG_PAGE_POISONING? Perhaps just leave the warning out entirely?
> 

Yes, only checking CONFIG_PAGE_POISONING is not enough, and need to check
page_poisoning_enabled().


Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CCF6C46470
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 20:07:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 122D2206BB
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 20:07:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Y6/CTKw2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 122D2206BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B28296B0266; Wed,  5 Jun 2019 16:07:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD9376B0269; Wed,  5 Jun 2019 16:07:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9EE3A6B026A; Wed,  5 Jun 2019 16:07:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8581C6B0266
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 16:07:45 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id u25so13576571iol.23
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 13:07:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=YWPCkjiDpsVKRA3zAFLVPrJDaYwckwujcOqte+GF4Qs=;
        b=gaLQXphbMxjgCqxAo+1dj3Fwl4KtbprghtWSoR8CvL9dT6pAvyHGQQ6tMqGNaO8UTm
         nANS3pQZ53WTD3lJlVT101YqnCa54p3sdr9oTZj29XGnOnk/3T9yCnn3Nx+khQrQljwH
         zI90ESbSdiuR3rBnw37OSwUV106oDG9Lu1SU56gAblNQBX7rnaUzuXjrUKPW2FZFt5ut
         WGpKIsgktbXHvNODtLd+1iAzjt73TX5U5YgEvsgE3BMY722uJL8FwAnSRAlBTxUm8a86
         l/GOHL9dj12aYOfhT1w313WyOw0IgYGzogiYc6CWECFIGu4AfVdqXjKn4lEdrgsUKn3O
         uzPg==
X-Gm-Message-State: APjAAAWeK/VT1l0/PCwRWKCfaW81fp8KWABTevhuHcUa8PZvzdiL2sGp
	2k1mMN/PQ9eulmiJGXSyo1ONUEP7WHk20bUHA48GXBkYm3yv2h6PT7mqBWWcfUUaxvqNcvS3b6h
	gqsRyUJQLbfrTKuGnGMLbmPZQ4WdIrUw2iBTNJBP0ApudAxxCifL3YY8XFWu8RxK8Cg==
X-Received: by 2002:a24:2149:: with SMTP id e70mr4698912ita.2.1559765265310;
        Wed, 05 Jun 2019 13:07:45 -0700 (PDT)
X-Received: by 2002:a24:2149:: with SMTP id e70mr4698849ita.2.1559765264299;
        Wed, 05 Jun 2019 13:07:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559765264; cv=none;
        d=google.com; s=arc-20160816;
        b=Zi9Fz+kXhgXmD5/U3AnmAhKzgf4Fc78uvZckKr2l1V/8LqL+q8/G4As8V+W0BzMr2x
         SiO0D6VI495JYwhX3+ZzfuHSX0aqQcUisSqfMH19fV9aV7YpIBxArMyXeEVYndKtKhfC
         0Pnq9VhwnQU/SJFe1cxX09OsP34uaLLbANvfbk4pWF6Q9WswsTpVD8/0b5LD6b1RDPKf
         4pAB92NFePMT22r3e8gxfCHCCPq0pZD/NzHwuYm7Cycml9s1tKlVak0RMzSkFyxnNxPk
         lfocBsZbe45v4Sb+58JxbKNehvkOfJHDr+CpEMdDMyL2lbBl+mhhwoFoT3zRpaWQCbz4
         yqvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=YWPCkjiDpsVKRA3zAFLVPrJDaYwckwujcOqte+GF4Qs=;
        b=qdc5gqIpyc62Rx3gP8SDNboTfkmRNh921b8cvefb0O+smbGBZqk0DsrHUL83UiImR2
         RjJfYadfqF/1q2jm292egk588vNH6+/FOsIQ2wnQS7xW/VHQg1AqaNn31vNW39ASuRw6
         Ya9fM/hvjYuagikIi/v8MtNZa6giHeb9xcm3xo8/kPsopA1Co2xE+S9u73mcoLa1SAMv
         14Wwyxa2cwX57RIq4LzGpKARQgCQMN5kKhS4vAGp1QdHCYzD+XA2zEOzCY2GzCl5DOOB
         yaA28oG63vvCvOfU9eTVhtKoIx2/VWdQlgYsxJV4oc6pB4vnowD9N7+aHQnSWr1zKN5C
         Wv7g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="Y6/CTKw2";
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l1sor4750553ioc.63.2019.06.05.13.07.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Jun 2019 13:07:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="Y6/CTKw2";
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=YWPCkjiDpsVKRA3zAFLVPrJDaYwckwujcOqte+GF4Qs=;
        b=Y6/CTKw2HpfFzRV8cVp90r2srB2SmP6at0zd+tEXm7XFl50kmu/Y3nIEEWGg3Kzk/B
         l3D3Qr4UiAJUphHXpmvTqTi4wbNRjrImrlG7ZnCCJKH8FdZqjq4BvR9hjClj79ZJXtpo
         wJwy3Sz8MDxzQjIUSDal0FQ4e3ED/l4WprxHOQB1SqDvdINs5Z2Iqe466nxFxl7DIM25
         bdtQ+7JbvDnxmhTWFmbnWKhDxV3HeUg0fR3ZqWqUeprL7yqliCoe6qJGgY9soYeL2+c4
         g5KyxxMf4S0cwbsB+gEsHrj/UZW1Nk7qSFO7PfGWDWJQGbArg1y384v4TeP+oCHceLWr
         6KCQ==
X-Google-Smtp-Source: APXvYqzGleq5vDpqLVlVafId0CX+B2A32E7+JeJwJXNMpga7x9yP1fKCekdulEwyHbBdx18n2S7Lth9ehJe4hSJLcVk=
X-Received: by 2002:a5d:9d8a:: with SMTP id 10mr9444816ion.179.1559765263703;
 Wed, 05 Jun 2019 13:07:43 -0700 (PDT)
MIME-Version: 1.0
References: <CABXGCsN9mYmBD-4GaaeW_NrDu+FDXLzr_6x+XNxfmFV6QkYCDg@mail.gmail.com>
 <CABXGCsNq4xTFeeLeUXBj7vXBz55aVu31W9q74r+pGM83DrPjfA@mail.gmail.com> <20190529180931.GI18589@dhcp22.suse.cz>
In-Reply-To: <20190529180931.GI18589@dhcp22.suse.cz>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Thu, 6 Jun 2019 01:07:32 +0500
Message-ID: <CABXGCsNTjHhpK4OoGxo+rcp60F0pAc377KpdsrgWptyFjfLLog@mail.gmail.com>
Subject: Re: kernel BUG at mm/swap_state.c:170!
To: Michal Hocko <mhocko@kernel.org>
Cc: Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 May 2019 at 23:09, Michal Hocko <mhocko@kernel.org> wrote:
>
> Do you see the same with 5.2-rc1 resp. 5.1?

The problem still occurs at 5.2-rc3.
Unfortunately hard reproducible does not allow to make bisect.
Any ideas what is wrong?

--
Best Regards,
Mike Gavrilov.


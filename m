Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59480C282DA
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 17:18:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15A852175B
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 17:18:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="EbOLckE+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15A852175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 900966B0007; Fri,  5 Apr 2019 13:18:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8AFDA6B0008; Fri,  5 Apr 2019 13:18:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 79E0B6B000C; Fri,  5 Apr 2019 13:18:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4112B6B0007
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 13:18:40 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id p8so4824642pfd.4
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 10:18:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=hqVjLLqJXHIVHZRkw4agyBYtGmnqgKev2T7NptFo8e0=;
        b=Aic4kqDUidGwQzPLF3TtDnXm80vB4PIDYYZD9ZhcnfjSWkyyppyDab6vLKjO5H/MRr
         p11vDSTWW+0pJtbK5FSGJ0avkR1bAvPE6tSIz4GPqsalCRYCcBX1yzUS2SwwzjuEWYbc
         LyLktTrkTqg52YEwVq0JCYUzmif3r3Rck+aARCVU0tRjP8iOyKmvuLlAKmvExWTFs6zf
         kIJTxhB/6kvzKAVAarWa4ZVFskTJsJwuAnea+vyNbYvQDSujllkV+NY9hHIMtc+knbCH
         GV0CPK5IjeqjZCu6eqUyMh82QlVjNnaINdrfVu+YYRsFx1+2KYroTSsxAbSVfEWx+69H
         iUZQ==
X-Gm-Message-State: APjAAAWLno7dy3h5D0bPin/m+tc5NaqHy/cQZlsnDNFGDQOwdOV7CYxf
	OEzN9qYd1RNSlakH7qBpgLZqOQV0Z22D7FU3EPWhkAHtfw/9I6+zMXfz3OiJOXptZ/Ajh8J3/1o
	3iM/P0ZaExNLvPIJCwK//0VSiSZO3oM3cvWfTA+oywCgrZtQCXOzuyEWETmBazh8ukA==
X-Received: by 2002:a65:6496:: with SMTP id e22mr13202181pgv.249.1554484719744;
        Fri, 05 Apr 2019 10:18:39 -0700 (PDT)
X-Received: by 2002:a65:6496:: with SMTP id e22mr13202104pgv.249.1554484718940;
        Fri, 05 Apr 2019 10:18:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554484718; cv=none;
        d=google.com; s=arc-20160816;
        b=xPGEW3jbjOGT6P1w19CIo7Ml7l3/fYnmM4ofHV/6alO9eR6ZB9a1fBHZWxvA8t+d1a
         d26c7bsu0sXKAsN/lXBIuRhBT1x22BUzhbREjbBJLOEMPPxrwqvjGmRn5fLoNUyVM89+
         pSnYy7l1uznLCp+0yv/H2hW2zizyUEyB0owcXaLuAWF3/BFTXRGXuMqbNrGr4rsmJ/T6
         sksVc/VjinmswpO7LeyfmoZkNjsK532TMNHy2JI7BLAqIGVByMPVXPRC3Ilg7uSaswBy
         bf3zDkmujakuw20IMUu3FD6yJB4MdruZ63Y978bAEF83TQpnIOxHN77aA2XGiF0W4oJO
         8kXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=hqVjLLqJXHIVHZRkw4agyBYtGmnqgKev2T7NptFo8e0=;
        b=0suBRhxz3BYMz3Srek0sMuU6PYCxnWj4mfLSlxJg9i9xsGgZ3l+SDfUNm7gTEIb966
         2WQaQ90dCz/kinHpmxo7fIDkXjrfIMqihz3U2oflWp7ld+fTb34I5zA7a0fjR4fRa2Y2
         hP+c28Rx6Ce+plWXLSNVB5Ir867otDyko8SPrskNJM0BuBhXnmKn3zKrA2m1LwJNlilT
         6IBerLvmhob7P8vdDwF1FZ32mdoPEkgv6DH0fGWDkk+z1SD3/Myy7kLjpzwKETowicea
         a4NbMYdckNQJVHN7QuXbszG4DhfKQbV8s1N2/bV0C/JMrbOn53C7IFOvsM4/szY42dOF
         cTGg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=EbOLckE+;
       spf=pass (google.com: domain of ndesaulniers@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=ndesaulniers@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f1sor1310224pff.61.2019.04.05.10.18.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Apr 2019 10:18:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of ndesaulniers@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=EbOLckE+;
       spf=pass (google.com: domain of ndesaulniers@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=ndesaulniers@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=hqVjLLqJXHIVHZRkw4agyBYtGmnqgKev2T7NptFo8e0=;
        b=EbOLckE+QInONXLlNWKYel3NJGiKrh//28V6JiKHoekXnaWJEOnMA/wzzTMpAn+4V1
         Q1bih10evC9y95Y7l5Zjr0W7971tdPOCfbQrbh9sVt1FA2URixmRsPx4D5prztDqLPOU
         YqmEGNC6nw62YsYqXfpFnJKvEV2EhhpUuB2FudqgGdTqOtc81ZHgH8iJ/SuTteMIhEgs
         dhUfoNbBz5QQS35qgPREc1YHs91aYjB4BOwHsuFDYyuaTnoqAsIG/ViuXAYF0PylhP/t
         udTQF+imui84rIiFW0DfrQfX7CfoTWH845a0yXTOG+H+2wmMaick2516HKYeUcL08TIb
         Rxog==
X-Google-Smtp-Source: APXvYqxJZn7bBf4oXeCAzQ0xcYU7w0/3wcsx2rsWjz5yyvb/Q1eD2mX/xF0s3t1Ors8XGHzn5yU+BfWd6gHp1LZ8VdU=
X-Received: by 2002:a62:14d7:: with SMTP id 206mr13520128pfu.162.1554484717893;
 Fri, 05 Apr 2019 10:18:37 -0700 (PDT)
MIME-Version: 1.0
References: <20190402030956.48166-1-trong@android.com> <20190403152719.GH22763@bombadil.infradead.org>
In-Reply-To: <20190403152719.GH22763@bombadil.infradead.org>
From: Nick Desaulniers <ndesaulniers@google.com>
Date: Fri, 5 Apr 2019 10:18:26 -0700
Message-ID: <CAKwvOdnJLOCKXZQcrCrsM1j5b4U_0vdV7JhbDtBUdLe3cMYp4A@mail.gmail.com>
Subject: Re: [PATCH v3] gcov: fix when CONFIG_MODULES is not set
To: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tri Vo <trong@android.com>, Peter Oberparleiter <oberpar@linux.ibm.com>, 
	Greg Hackmann <ghackmann@android.com>, Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org, 
	Randy Dunlap <rdunlap@infradead.org>, kbuild test robot <lkp@intel.com>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 3, 2019 at 8:27 AM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Tue, Apr 02, 2019 at 10:09:56AM +0700, trong@android.com wrote:
> > From: Tri Vo <trong@android.com>
> >
> > Fixes: 8c3d220cb6b5 ("gcov: clang support")
>
> I think this is the wrong fix.  Why not simply:

I spoke with Tri quickly about this proposal and we agree it's a better fix.

Andrew, would you mind dropping:
https://ozlabs.org/~akpm/mmotm/broken-out/gcov-clang-support-fix.patch
?

Matthew, would you please send that patch with a commit message?  Or
if you would prefer us to send with your suggested-by tag, we can do
that, too.  Whichever you prefer, please let me know.  Thanks for the
suggestion.

>
> +++ b/include/linux/module.h
> @@ -709,6 +709,11 @@ static inline bool is_module_text_address(unsigned long addr)
>         return false;
>  }
>
> +static inline bool within_module(unsigned long addr, const struct module *mod)
> +{
> +       return false;
> +}
> +
>  /* Get/put a kernel symbol (calls should be symmetric) */
>  #define symbol_get(x) ({ extern typeof(x) x __attribute__((weak)); &(x); })
>  #define symbol_put(x) do { } while (0)
>


-- 
Thanks,
~Nick Desaulniers


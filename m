Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7245C4CEC9
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 17:39:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5753A2067B
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 17:39:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="NtTZWOJ6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5753A2067B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AEAF06B0003; Tue, 17 Sep 2019 13:39:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A9BAF6B0005; Tue, 17 Sep 2019 13:39:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B13D6B0006; Tue, 17 Sep 2019 13:39:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0207.hostedemail.com [216.40.44.207])
	by kanga.kvack.org (Postfix) with ESMTP id 7C6B06B0003
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 13:39:54 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 1AB33181AC9AE
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 17:39:54 +0000 (UTC)
X-FDA: 75945125508.26.scene16_9098524403f49
X-HE-Tag: scene16_9098524403f49
X-Filterd-Recvd-Size: 3272
Received: from mail-pf1-f194.google.com (mail-pf1-f194.google.com [209.85.210.194])
	by imf45.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 17:39:53 +0000 (UTC)
Received: by mail-pf1-f194.google.com with SMTP id x127so2567548pfb.7
        for <linux-mm@kvack.org>; Tue, 17 Sep 2019 10:39:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=yQGk0/8lgiYPogMBH7GGBJWsq/bIXk08DULJA4Ggl0k=;
        b=NtTZWOJ6sZPprJOVH0W4hwFThisJKK+mS/VHocfVHVb2P9H2l9T5aHpChwouDxkwmE
         P49mEJJBAVVcwAOr9zUQvc3TY6g7qH1YnPBmLL6C8kaZ+bVjQzQTzqDTut2MaiTkY9wl
         QF6VMIptGZdvKaN6CHCHDorvDVZ2wL8ePNFV0=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to;
        bh=yQGk0/8lgiYPogMBH7GGBJWsq/bIXk08DULJA4Ggl0k=;
        b=j1VjIHJd+XE6dxbC9hhfn7Y0EHUTvkIuZVDi/U1mQ0fPtKHnWD3iGWLR61leyPVf3B
         Bc/dl01YsFTkchIETr9c4UHqP/SFFB3xkgGx0xZia03gdjnZRoX62avJDbeUk9oqQYeD
         88ETxBLvScpRlFLe+ntg3r+3NmwN7V0t4nu1jO2BELF5b/ONF1QKXNoNoZjjBZAuYqFp
         Sr/YJdHWiZw+mFtmicwvvtIaW2ecnG6f9gEzivUBl8ZW2qbBlM2p+s+TmMVTliWwkaFx
         VuMLybwwO3KfS8X0wpGy68t28P3HG6DseTl64TISQS4icFgPO+lsPrDfgsKrmNl9n7aR
         qR8w==
X-Gm-Message-State: APjAAAWZ3DaKKXERMo/+XGPnIoE2nn8jppkN5wQg1XdC5uFmTQqXRx/b
	hHvIZ/bh2z+GOk92lS3PEYf4PA==
X-Google-Smtp-Source: APXvYqy6+hMb62AAD7PQRSOuTFktsmPGOjE+m8dJyhXRgqu8ZVw0TdiA88ecI5b6khAzl2L7X7g00w==
X-Received: by 2002:a63:3585:: with SMTP id c127mr8016pga.93.1568741992410;
        Tue, 17 Sep 2019 10:39:52 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id w7sm3008939pjn.1.2019.09.17.10.39.51
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 17 Sep 2019 10:39:51 -0700 (PDT)
Date: Tue, 17 Sep 2019 10:39:50 -0700
From: Kees Cook <keescook@chromium.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH] usercopy: Skip HIGHMEM page checking
Message-ID: <201909171039.09E75C2@keescook>
References: <201909161431.E69B29A0@keescook>
 <20190917003209.GS29434@bombadil.infradead.org>
 <201909162003.FEEAC65@keescook>
 <20190917163606.GU29434@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190917163606.GU29434@bombadil.infradead.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 17, 2019 at 09:36:06AM -0700, Matthew Wilcox wrote:
> If the copy has the correct bounds, the 'wholly within one base page'
> check will pass and it'll return.  If the copy does span a page,
> the virt_to_head_page(end) call will return something bogus, then the
> PageReserved and CMA test will cause the usercopy_abort() test to fail.
> 
> So I think your first patch is the right patch.

Okay, good points. I'll respin...

-- 
Kees Cook


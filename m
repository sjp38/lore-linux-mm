Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 035B2C43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 18:13:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B895F20675
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 18:13:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="A0TV9H7/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B895F20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CB848E0007; Thu,  7 Mar 2019 13:13:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 355708E0002; Thu,  7 Mar 2019 13:13:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D0198E0007; Thu,  7 Mar 2019 13:13:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id B875E8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 13:13:00 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id e18so8931872wrw.10
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 10:13:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=x0bRJ6egfPsspCgoN/1H3HOQ6tPlJYzruFIgZD5Z3UU=;
        b=K0qKLxvZaZ1ofcbpaYCvWhzNCByi+ZzTuykFA8HyWyNJ8jZw3Rfm2ns4MkHjqTwFUK
         1sLk43QX/GRLCkfnFrHJHnhrJ2Osn77WzMqbg+4WFg7XItZlJ09KmpryDhIBbm1AC2Gs
         0TlCprUmoo/JzIqxtjWB4Ncpe68vPaW2QL5/BgOjLPGOvmQUxszki6HWz9O83DXMMAek
         PTz3P9BjHvlwNQo9jifEO0ZCttANQQX6Q9pAlKPEqL1mfp+hfH+dvXW8qa87nKQRQwwG
         p74gqUbWbcT35QtcmaKuqsmlMnpRv1id80eBYyHwaJ775v4IJ+aLJZMUvNc0RZev2Kgt
         9wZA==
X-Gm-Message-State: APjAAAX35IYo8ahSME4u9U0NfKoJLBew+S7JpGmVR5JYrA2TjfQTbPdS
	85UGr3gkcoKIBx86w7AT9sD8m4eqk1xzxs0Fdg60vVfeczri41ydaTZNPcAd1yaIhlPUBEDTpoy
	4QZHzjlnchXnJ5vuLBKpWHcmqYu6Zq4G9wzp+tIJae/x13z9asTZkVEOyvPHeZfAX5mZInhMKPu
	QnGQduio3udUsrFNyBRaaqauiJ2lXTk2SFgXbrWKqxrxDngOZbjKL8qqJrXUNnhRFYkDYUf89na
	+/CrRf0A3sQ7hwlSA1MGLW0qnGFXf5FqDLF8MbFUR/N51mXkehCxAWniJGg3EP2wRzlzR/J70M3
	M2w8ZnQaAI9BcA9hTa+RqtLj805cKn7hIdaSbfmWOi3/ANUbxBgZsmbpLpMPEQbOIU9fmHUfnFJ
	U
X-Received: by 2002:a1c:6789:: with SMTP id b131mr6492336wmc.22.1551982380327;
        Thu, 07 Mar 2019 10:13:00 -0800 (PST)
X-Received: by 2002:a1c:6789:: with SMTP id b131mr6492289wmc.22.1551982379371;
        Thu, 07 Mar 2019 10:12:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551982379; cv=none;
        d=google.com; s=arc-20160816;
        b=lztYhuhgZkp9je3CgPcI5NB0s1x/wlQhfiqWGeH58pWCwzR7qY7NVOE/acPBB9FKo6
         V7joMj2zCFSBPKtpjKDOhegwqyltGdrH8DHUdo0NtmHTinrCUfp9wBGDB5qHprCl3Bj/
         4GSBv5fQJc7Nu7JC9BIkP9YFkFLerubotecLlXQQjO8sqjZhznbbywuLtD49Fkm2C1I9
         a76h3TqUhkcy8HQOsNJ4+mJSug8F30IwNx6h9NiT6eYX6dXyJ+yV2YNIpHB0L+hv8peV
         wYBgCT19Zn26eTjJkAWSMg+JY1Yxgzo2NWs4jF3m1wIoiUoD9lqwlwZyn6oLX45C5hKX
         0c/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=x0bRJ6egfPsspCgoN/1H3HOQ6tPlJYzruFIgZD5Z3UU=;
        b=NjeFhtaIrsdrB6bZrYFiGoALsrgQFZBsRmrebitxg7Lp3U9Ad9oJ0Gl+UAK3SIypen
         wVauBh+wiZ4dMHf+YCnBP2oXvi3+B7wF1hbCrM109Sk359N1pWny3pc8bEHRO9jfJUVQ
         Ox6Yqs3D4VDgD/KQ6IK65n7EuLrsE3wMDP2A5LYCRCxqd2mfgK2D7PLrj/5WQGpdFz69
         gvIg1l4Iyv1Q75qPXkuunDnvdBSvuv27qNdOM5FEQi1vbSsuCzUKtgp7XBA3NcEOX+kP
         zIuvNj8lv+9gkgZjCslhcgk5QDweUft9m3C9hm+RFlckFlRcxy68GfeDHgnn51Sb7ARV
         fQ6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="A0TV9H7/";
       spf=pass (google.com: domain of adobriyan@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=adobriyan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x10sor3882169wmc.25.2019.03.07.10.12.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Mar 2019 10:12:59 -0800 (PST)
Received-SPF: pass (google.com: domain of adobriyan@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="A0TV9H7/";
       spf=pass (google.com: domain of adobriyan@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=adobriyan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=x0bRJ6egfPsspCgoN/1H3HOQ6tPlJYzruFIgZD5Z3UU=;
        b=A0TV9H7/YK7+FKEaeWOHmBb0ljoEy5KkDpU6xAZM0fYE+ovg7p+5yyhTu8SXOj9LCP
         1RBhBmbWUA/oMsmZtUmi5tNsr77W/i2uijPYRhLi/QRVLhC7NI/W6vgvgvYT0FL5II7o
         mXiHx+UucN7418Ye10M5ukw7gOKjqoN7+QbjNGGvClcNQoBcFojoNcP4URJLaIhvBJVr
         gM/izONWdDNBhVW2G4YzmfqJeHe1XdTC2deqjcNWVlO33OQaPcNvcswyN4VuiNIik4bN
         Kop0wkgF3x4WoZsQ1Miu1cIVRcw038FTBMq1a2RwXNKD269aAtmWCBZ1xUmm65hqeu/j
         Scsw==
X-Google-Smtp-Source: APXvYqwW01MNLrutpvpsRabKiPYhrMSKFD2qOZknjfXvNnoOtsgy1KBn1duwg7ymzhs87kzDXcpyZA==
X-Received: by 2002:a1c:a9d0:: with SMTP id s199mr6471648wme.142.1551982379054;
        Thu, 07 Mar 2019 10:12:59 -0800 (PST)
Received: from avx2 ([46.53.242.20])
        by smtp.gmail.com with ESMTPSA id o12sm9063017wrx.53.2019.03.07.10.12.57
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 10:12:58 -0800 (PST)
Date: Thu, 7 Mar 2019 21:12:56 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
To: kernel test robot <rong.a.chen@intel.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, lkp@01.org
Subject: Re: [LKP] [proc]  3f02daf340: kernel_selftests.proc.proc-pid-vm.fail
Message-ID: <20190307181256.GA10410@avx2>
References: <20190203165806.GA14568@avx2>
 <20190219094722.GB28258@shao2-debian>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190219094722.GB28258@shao2-debian>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> selftests: proc: proc-pid-vm
> ========================================
> proc-pid-vm: proc-pid-vm.c:277: main: Assertion `rv == strlen(buf0)' failed.
> Aborted

vsyscall mapping enabled, I'll post patch shortly.


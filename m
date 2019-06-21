Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70066C43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 12:50:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32E3C208C3
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 12:50:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="KMV986NB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32E3C208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B29918E0003; Fri, 21 Jun 2019 08:50:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD8AF8E0002; Fri, 21 Jun 2019 08:50:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A0668E0003; Fri, 21 Jun 2019 08:50:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4B6228E0002
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 08:50:36 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l14so9045362edw.20
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 05:50:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Z2tMjjHGDWr6TC4+F/hrcpULxftEwauRCW8IXg/I2bA=;
        b=C0MjhC5NN1SKpguGxBxbBMrpXMYVdNpMUezyilwrRL5wwGHR/kMw4YXcCN9jHoYYuh
         W0Kr/oG++XvELGNyVkgahdboOL4V1IsENb7L2SmOmt718BMneMaY5M20QstsvXBKlDJw
         RiMIDZGnK0ByBFaMHKgPlo02Iz8ZQ/FJB9WnFQpjnJhwbNNSmywTv6pTj4/QRECH6kbl
         pmWnjgPJF8xRuvNGZC114ZKsEDEYWEB+AJ120MdmyXDFnUQrbSAIJJRMoNyCOFLr02+f
         Lb0naq+CBVPJ4xTak5DNcT8TtNO+eHuEtXtnzt9GgVFU+hCHy2K5O+TFZfUyuLgplMDN
         lObg==
X-Gm-Message-State: APjAAAWwBssRd+3FCLNbomGGHrA4FV5YL7SA0eQO5rbHBFHdeGOhNoJa
	voSXjn8aCL06WLD5iJzGxVkMfQgCCV2PQ5+/BoOcHoMCP8maff+FsKQww7kI2InMU2JH4xNOv4k
	x4LlwliOMPWKGNzpcNYs/HLK+tQWyP+hYzosH58gt3mllJgWjeOfd8MiRqdu9G08qnQ==
X-Received: by 2002:a17:906:1806:: with SMTP id v6mr51459454eje.134.1561121435854;
        Fri, 21 Jun 2019 05:50:35 -0700 (PDT)
X-Received: by 2002:a17:906:1806:: with SMTP id v6mr51459410eje.134.1561121435166;
        Fri, 21 Jun 2019 05:50:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561121435; cv=none;
        d=google.com; s=arc-20160816;
        b=n3il3OL347spFFNrQG8pDtXfb73aP98lmQfR5SmmEM3JhtRwzucEHxhJS0hlneChm0
         pM8B4tpbp/qaDwd1f5uUJ64O5dblq5v3FFB3P+lq64hPZEdj6VB199wRQ2gpxJM1dD/D
         b+bRQQn+QKQ7errQssiPl0snfXWZIAaKvPqb5pKNYYX+ajtdg6qTaj71z6aAJjeRgUCR
         OwXBrWU9XxERS2uLPP6Dt+dDDEqUL0nccRvtOMzNYlcTrtinlQc+ZTAF17U8rzzlcBCy
         MWUQ/Vu5iOFJOU9apPzXTW5MBNSqGKEL0pvXUxKySh+pCIeZLM44pZtBfFraDIZpA7fp
         jJWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Z2tMjjHGDWr6TC4+F/hrcpULxftEwauRCW8IXg/I2bA=;
        b=VmfGXnuQU603xUxGKkQlTnmqbgOLcDg/uA4jrgbAjrwju4rFrnH5STE/qqRAST75SW
         WUdOaFsoY+cJSjrXegjgQsb42pzz8yeRTk3ow6CVDlX7UvDu8q4lKWHeOt+Tj79aL5h4
         INXXopH+q0A8pg8n33hp4AFTJGrs9eJwxaJu6sjwlMNRscMUYYHPpT4rud0+gK/5gAJr
         tXoPredd9IVEiF4bIBL73pCSDTNn5TeqziOrmlob5ITkryExe+msQJ4zYJNYR1W0pCGY
         qsPM2WdcdcAWj/vGnBe2OiRoC12zbqkLdE22O5mnM/GJ4iPkVUyH+0iWl3mkQ+smI8aD
         NEKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=KMV986NB;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l34sor2829133edc.2.2019.06.21.05.50.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 05:50:35 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=KMV986NB;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Z2tMjjHGDWr6TC4+F/hrcpULxftEwauRCW8IXg/I2bA=;
        b=KMV986NB7KPjgnu4A7v35qHPmvLovNUsc/f4WLxUsWOX83ibARZkrMAdC3l8dHhwOd
         9Emd/Ce61ss/t8awTADFq4E3JkWJlnQRTtkS+JcCs76BziAvw3RkpAVpQm26lqSnNe7p
         8NnMnlU07QvWZ5dpKMGNgRrP6VaOjcHJ3p+MhLLFUG4reVL8C6WxKyMr0pQa63+bBgkp
         3FjpRFZ43JcfRdxCJ2deZjVILa/Ec8wzFeXMggr6yroEP0zM6/VSREzwRwyrvLx+wKRM
         uR8fNmGm2rJmStb6bM3c+qMnG6DYfTbYFYv+OkIDn7eHm5vxyyXH26NXufspsmFSySqg
         Ew1A==
X-Google-Smtp-Source: APXvYqweJ7gocKDS8gE3t8eQGshiwXzlez9ixcfL+po2pdM4IWsLgUbCStRdAB74wQ5ruwp0TE+dgQ==
X-Received: by 2002:a50:eac6:: with SMTP id u6mr38726715edp.83.1561121434873;
        Fri, 21 Jun 2019 05:50:34 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id j25sm784129edq.68.2019.06.21.05.50.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 05:50:34 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 679F410289C; Fri, 21 Jun 2019 15:50:36 +0300 (+03)
Date: Fri, 21 Jun 2019 15:50:36 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Song Liu <songliubraving@fb.com>
Cc: linux-mm@kvack.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com,
	william.kucharski@oracle.com, chad.mynhier@oracle.com,
	mike.kravetz@oracle.com
Subject: Re: [PATCH v2 2/3] mm,thp: stats for file backed THP
Message-ID: <20190621125036.yf4yjqolu3bx77wt@box>
References: <20190614182204.2673660-1-songliubraving@fb.com>
 <20190614182204.2673660-3-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614182204.2673660-3-songliubraving@fb.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 11:22:03AM -0700, Song Liu wrote:
> In preparation for non-shmem THP, this patch adds two stats and exposes
> them in /proc/meminfo
> 
> Signed-off-by: Song Liu <songliubraving@fb.com>

I think you also need to cover smaps.

See my old patch for refernece:

https://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git/commit/?h=hugeext4/v6&id=e629d1c4f9200c16bd7b4b02e8016d020c0869cb

-- 
 Kirill A. Shutemov


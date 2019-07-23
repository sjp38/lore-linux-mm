Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD299C76194
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 22:36:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 694AA20644
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 22:36:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SdQIiqD4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 694AA20644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F20526B0006; Tue, 23 Jul 2019 18:36:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED1526B0007; Tue, 23 Jul 2019 18:36:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9A316B0008; Tue, 23 Jul 2019 18:36:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id A50E56B0006
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 18:36:25 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id q10so3713411pgi.9
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 15:36:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=zNouKbF6UyPadfEdFSK5fRF7G6CWHnxRN1FzAl+dNYs=;
        b=f8IWJ255bQGkpU3dSJ5WC+rcbSaLLmeA7QtJC1nLyRsdMzSCevJcnqSRSBs1zJcv30
         a6AqzFSKMP73hUK3ftd4BanwP68gudzbRVS4wzWRiz330oJuE56aUEnlYbNw8DMIvDmv
         pvpPjAC5REJrXLBQ/vhFVdmJcWD3PhGHKsHuly49o6+x/T6pf8Z98n3OqWYPCXwdkFUA
         lrHHCkkh3GHloXJ1FzKFsB2u0hI9jh8CUpcz57G0MRtXm6OdQbR5jIu67Ijh0JCakFlK
         6dsgulmOnucyXDUyQtVNa8uumr8OE1dNwNoNnfTBP2ET9svdh1cH+fLl5OsA/EExAvqE
         kLig==
X-Gm-Message-State: APjAAAVzWX7F85fYSL8pt6u4/cOs8USjbRYFq5hYGBk9u99eFSbYhjJ+
	8pM6MatU7fYtV2Tranen2ghcLr0UGa1JpUdScCLt0Zs44q9KmZdQR7i969rcU6vsmSOBbDN+Ce1
	VOfCwwQsmKaD7uNx4E6XWvFP97+4e/JLlxFAigssKDB7LZd6by91a1wNffyBfWIw=
X-Received: by 2002:a17:902:f087:: with SMTP id go7mr82392853plb.330.1563921385385;
        Tue, 23 Jul 2019 15:36:25 -0700 (PDT)
X-Received: by 2002:a17:902:f087:: with SMTP id go7mr82392802plb.330.1563921384723;
        Tue, 23 Jul 2019 15:36:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563921384; cv=none;
        d=google.com; s=arc-20160816;
        b=ly9Jb5LwO3ol9Xr8qeegzsS4mDTAiRMSnHwawcPEGwkRiRVoJ4mAUk6AsLFKllmNl6
         5zlMER78cwxvI5BwCoHX63p8ieLfe4aQUMByLsum8A9cf9Go/vKKRYdn0IXY3wf8tgR0
         KlOrmYYciI+jjVIwerhJySd4gHxfE2F4JdEzCzj7i7x7+a3pTBwEKoTtUTZdLuwzRh3I
         xAR+yeXSt4KWGlJA+2Vs1ukeWKALadlisPKsV73Ni5V2g6rYIhsfa2rEWMsAA09t8GIn
         Ki6QuOBZarZv421UCUxNO9SlElqvhNoCwv3M1LsL6FEx1ABXOvEa7x3/CTtIu77fnSnm
         J0jw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=zNouKbF6UyPadfEdFSK5fRF7G6CWHnxRN1FzAl+dNYs=;
        b=cF/LKuZMs1Iu3+ljtjVVt3NOKe0C1G9acAQuU9Yu6UBKtPEcGxOixrTr/oVfMpXB9t
         84bWzHdhLLj2b29cLoxNxIFWWZN9PSUZULq3foGBR5oIhndORgPUClJFC8/tcrgvAm6V
         8uWrQUpBOK8MzJkjKMA5C4fR5roDCkcz9CmebsfTjPtlh+ywovfk6yT8GMQ5cFVmkXy4
         Kw1BKVNDgbJhBMQoDjmY/hJyIqKCLe7r7ee2mAo/ls90GoTAc59zSampfMzDWOQaGUSS
         ixiCl/YYTf81MKSAUvSNfaOeB+iSe1DQIExsLy2Tquu4SZB+G9vEBBkHgmAKKlEOfJK3
         qBzg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SdQIiqD4;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h26sor25654602pfo.20.2019.07.23.15.36.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 15:36:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SdQIiqD4;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=zNouKbF6UyPadfEdFSK5fRF7G6CWHnxRN1FzAl+dNYs=;
        b=SdQIiqD4fkEQwr9X83RCA6yuwNBY1uChpKnXh3cAh+UZV7T/q90T66/ebWnSWzMdU1
         4ZhW4dn/MufMU2L+7JiJDj0tARsd7/JfDcK7Kqqk3vaKGtlGIJNFTFOKuIVEJ0tJg6HV
         nJBlNrJlbG4z+e88LPyvn8BrL/xxUJQuiugCiM1POSvapwm84nYrkEXh/Mp5F/0QCKHD
         T4d7iSWVbnhNQvkYjTIxXZMgF9DK7sKqcgjD1ReNDbfobnDjlowVaYpWEDPDMZN2xhW7
         pis75BozdMnhMsLgEScEd3kHzIXXtW8zbGK+ErLn5nFgdmWdRJBTzk0v8ZxIrsyj4e4i
         052A==
X-Google-Smtp-Source: APXvYqziGHn+6jGrdziu5cLb9QnyDXXK2JmIkImwr7M2iRolvR/fyo5r25/cJX4zAbOa2Ux1/H46Dw==
X-Received: by 2002:a62:5883:: with SMTP id m125mr7941308pfb.248.1563921384228;
        Tue, 23 Jul 2019 15:36:24 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:2287])
        by smtp.gmail.com with ESMTPSA id w132sm45870833pfd.78.2019.07.23.15.36.23
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 15:36:23 -0700 (PDT)
Date: Tue, 23 Jul 2019 15:36:21 -0700
From: Tejun Heo <tj@kernel.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-mm@kvack.org, Cgroups <cgroups@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Jens Axboe <axboe@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/backing-dev: show state of all bdi_writeback in
 debugfs
Message-ID: <20190723223621.GF696309@devbig004.ftw2.facebook.com>
References: <156388617236.3608.2194886130557491278.stgit@buzz>
 <20190723130729.522976a1f075d748fc946ff6@linux-foundation.org>
 <CALYGNiMw_9MKxfCxq9QsXi3PbwQMwKmLufQqUnhYdt8C+sR2rA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALYGNiMw_9MKxfCxq9QsXi3PbwQMwKmLufQqUnhYdt8C+sR2rA@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 12:24:41AM +0300, Konstantin Khlebnikov wrote:
> Debugging such dynamic structure with gdb is a pain.

Use drgn.  It's a lot better than hard coding these debug features
into the kernel.

  https://github.com/osandov/drgn

Thanks.

-- 
tejun


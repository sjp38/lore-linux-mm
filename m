Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C195FC43381
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 05:57:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5CD5B2075E
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 05:57:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tqmK2RHc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5CD5B2075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B95486B0005; Tue,  2 Apr 2019 01:57:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B46D96B0008; Tue,  2 Apr 2019 01:57:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A0D9F6B000A; Tue,  2 Apr 2019 01:57:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6A6BE6B0005
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 01:57:16 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id u18so9978656wrp.19
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 22:57:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=zqPIMCgjn4CkXkrOXkctLP/edN2VdhXVbKkBnLc+HsA=;
        b=VCU+0bkyzkVg11ib5/sy2MoRRsGf3k+1hXj91pWhBbFAM1A85QMrRUpmM0J1dWm1yr
         NAhrwFHm2dqwS8gKRv37o83w7JRUXllvcEGFGHHKUN1EPs9fsZo1bZW0dfAIfMbDtuVw
         2ZOGuQVy/TOvXhD/9RbVV1MQ9z1KhPgchYlyuk7o7QEzYEsFFWRRBuLVwMD0WZtD1+Ye
         rRcbbExjvjP45hdo8rh5336YF/KPrvbMdm2v8otaeAHYqP3+EkF66nk6ZkILs9oCm8Z7
         gyEc4JJBwVwL6NwpcpZqyq0Of2cMZX2XYrKjzB47pHNIODKXK8EoYneWeVnXyF+H74za
         QPQw==
X-Gm-Message-State: APjAAAUysM55tNWbtRbiWahQgqKBGY6C6Yt3GOAAfFroXChBHt3EAwWD
	Kg9UvnxdQNe4VEO0eThO82qJ76NXlfl9ZifnstRyMtka5bhF/Vbn+IqJ1Nc5jZlXIN/NP65hwZL
	O7Bom+Y9XJfk6Ak5ZTdDO6sDjpyAedDSrBc9Obzkf56YVvXUIANRziwL4S0pB0fe2sg==
X-Received: by 2002:a5d:6646:: with SMTP id f6mr9743385wrw.68.1554184635758;
        Mon, 01 Apr 2019 22:57:15 -0700 (PDT)
X-Received: by 2002:a5d:6646:: with SMTP id f6mr9743348wrw.68.1554184634921;
        Mon, 01 Apr 2019 22:57:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554184634; cv=none;
        d=google.com; s=arc-20160816;
        b=sChq9L9rtgX6fkA7xrFib4ZjEW07NVHPrJapsDNgn6PjstfuJk/GI+/Cfka9O7SBcV
         oz7q1SZv+SaHm+FPF9H5nvUv5R/xC09VD+aIqG5PVkfiAaboK7Xcj21XrAV0W1EcBKRT
         SRD+Tvj6sOPPMcolnALPfGqiGTyyEifZN3Db7syhNvDn2ZsUB15miII5VeL0Bp/HMtKi
         5QPpA+yEYfRTvRCqpfLtp+ZbCQ73HU97QS/CuejIyf1zSEgMfeq4rRlCk42xLaKgSTEC
         dcc7IoMuOKkaaViTrNTGaBvpPF+FazP7/e2Df8cM3NRbd82XCgHf2kJVqChMBei0qrqP
         0IhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=zqPIMCgjn4CkXkrOXkctLP/edN2VdhXVbKkBnLc+HsA=;
        b=uO7OueFixZhroKlfLVQVX9fjXG11v3yJ33+e6aaU3rEuwxOeIcbSEwqCydsBAbIo0B
         JBs0SdQVwgU5CqlEcQU1noYsjWfyMqk1I4GRFXZp/3Z3GSmV4YOWv3nF32nIVlM6ZILz
         k7sYfztIheG5ldV5AuIzEsWNbFBGWkEvDEgeS8SlOA12XraTkF/pn91Qf7b6gjNVQu7V
         oObCIhGHWUZ02hZk71Fosip0jTB0mWF1nV8Qd2BHaBov8lW5hyds0eF+781eA/3vVG8i
         Q+DYia4KiwL96NAhuSVffJ2Am6Q7xreSr71lxuVufPMuEDM8nNYwYFYmCXuhyCJIeP0A
         eQPA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tqmK2RHc;
       spf=pass (google.com: domain of adobriyan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=adobriyan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x3sor7124295wmk.9.2019.04.01.22.57.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Apr 2019 22:57:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of adobriyan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tqmK2RHc;
       spf=pass (google.com: domain of adobriyan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=adobriyan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=zqPIMCgjn4CkXkrOXkctLP/edN2VdhXVbKkBnLc+HsA=;
        b=tqmK2RHchbJBdh3gll7YSfmeW2ub6TrZddm2YjQmhLQNH4If1OhorWGGMXofvmvsZx
         zw2DlxUEmiizXcMQYCNSmiiFnKjxbxu3YlCitgt6sfnbBEnWKObHhPssxgle8aZ5sF4z
         MvxhmpYRsDHvoyEw0wy/v1ENPxvSEA9tsWKM3u4pm9kD08II/3mjVUxOwCc1jN6AM7Sh
         6AapNigbZ5JWvsS0s1FcOIZkih3nTLp9hT2wvyehxn+pqyTdlP95gQh/fY6BfvqR0nkW
         Sr78sMUy0wHGCSkLwMR3SvLBWFqgAgImzjX0buaAWN1nagR/7zTqL9nJqo0dRyjOePs2
         znAA==
X-Google-Smtp-Source: APXvYqyeOJBVAsa/o0RTnTneAibpA3f2Qioi2K4yCMqb4SgWlDBd+lG6pi3Sb3nwL7RHAjNv/Hw3PQ==
X-Received: by 2002:a1c:38b:: with SMTP id 133mr2099803wmd.26.1554184634475;
        Mon, 01 Apr 2019 22:57:14 -0700 (PDT)
Received: from avx2 ([46.53.240.21])
        by smtp.gmail.com with ESMTPSA id i18sm13080066wrm.7.2019.04.01.22.57.13
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Apr 2019 22:57:13 -0700 (PDT)
Date: Tue, 2 Apr 2019 08:57:11 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Subject: Re: [PATCH] Bump vm.mmap_min_addr on 64-bit
Message-ID: <20190402055711.GA3078@avx2>
References: <20190401050613.GA16287@avx2>
 <20190401160559.6e945d8d235ae16006702bfc@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190401160559.6e945d8d235ae16006702bfc@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000208, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 01, 2019 at 04:05:59PM -0700, Andrew Morton wrote:
> On Mon, 1 Apr 2019 08:06:13 +0300 Alexey Dobriyan <adobriyan@gmail.com> wrote:
> 
> > No self respecting 64-bit program should ever touch that lowly 32-bit
> > part of address space.

> Gee.  Do we have any idea what effect this will have upon all userspace
> programs, some of which do inexplicably weird things?
> 
> What's the benefit?

Note the date :^)


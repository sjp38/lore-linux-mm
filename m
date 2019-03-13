Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20CEFC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 16:00:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE45920643
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 16:00:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="dGdqiWPo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE45920643
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66C358E0003; Wed, 13 Mar 2019 12:00:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F2C48E0001; Wed, 13 Mar 2019 12:00:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4BB5E8E0003; Wed, 13 Mar 2019 12:00:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1E2258E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:00:23 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id f67so3015732ywa.6
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 09:00:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Kfs3heF+8ue5fPhJOE/1L32aZGxH5YHBEa9Vc48MxT0=;
        b=MDNVHlH8kToQNxd9Iz2Kydc6VOsePKyPuykOfxFIw7wiXrVeTe2pqxU52QHFmEVxGs
         3NW42iIIoGkvApaFfIG55XcfK3oRo3vmPpWbeyzuZrfgzcvgTyYxFMvzlkDIWhsICiRn
         WFpUTrcv8OAlH8AajV/mUF4vEoE/JGINGCA2ocYeoyz2RzpwbpAA5kqeh9wCaZ6PfDL9
         cF4aZBZhKwwVFKuSBH9MpWYfUh2xjIJdtQW8TIDFVkbaCZRJYZqXwxvJm1wwWD/bod8W
         HxqcFgsxp5LpfNKcRW04qnZdrIf7Jyl88t2ZakkJ79ZbqoiYCjrxGgCj+IFrCFZdIVql
         O2xg==
X-Gm-Message-State: APjAAAV/kseySK2RePeUZK1ahpqMPHr6SafTVdOno5YConPhrdJaZLvp
	6HLPjGeEaFjZThq2t43Qi16sTarEmTmACWLwWPDahv+8TkPZZeorvgEmZAVQbpy4M/aan3vfuNG
	4mZpr53NfI+kDDh4PPLxbfzyJ2bimfbEWEDp3DTTSAcH2VV5nMA9wqCYKcT9kkPbzD/q34NzYFT
	GZiHWyq4xkdXcrxAq7L7EqjGaTUIKzz+QiJwewqxUvGJ2O6LC95GyS9y5MGWGEcIB4HSTxi7SrQ
	KJEKRJt1LqyigYxQ4PKSjLOk2sLcviQlfGN8aTHIDldBxTD4/wnYIZ+zqTCpzYaulk5USQp+Cvt
	djCD4lWwUNcgJ1z5Tr9zE/Qv4edxn3bytpbE+UbUBon8ZV+lmNlQozS06gImDwG0J19VyiSdrRI
	t
X-Received: by 2002:a5b:51:: with SMTP id e17mr5848959ybp.64.1552492822777;
        Wed, 13 Mar 2019 09:00:22 -0700 (PDT)
X-Received: by 2002:a5b:51:: with SMTP id e17mr5848871ybp.64.1552492822033;
        Wed, 13 Mar 2019 09:00:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552492822; cv=none;
        d=google.com; s=arc-20160816;
        b=uIf95T4uvZsLtrChGCNbI2RXu1IKUdmV4OnjKnLvo0/wX4zE9vLAEZLznEW1rigw4z
         egY6Nn57GTzMuw1qFcWM1i/K2+zywTg/V4A08Csz7AdyvcvOJszkRku8W7mvSIEcegZp
         66LfBIwwstu0PAKJtXO9D9sWApp/GaXWvYZwq+4sEfBsdA03GydZEVgmzjhoTvoPMZ0F
         NvfZmu0WtBTRt69yroIrWKrnvPETEk5SQRwEdenDeId8J0qDuJ/zCfdoC/veA5xJtLnO
         KnifJBHV1pceJ1T7v7uM3ia9TW1YJn7GhVPZ6Zyy0iBR14UJPTNiI0dYINGki9ya1vZK
         ZC4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Kfs3heF+8ue5fPhJOE/1L32aZGxH5YHBEa9Vc48MxT0=;
        b=zH4mOHbtORXzPPZTjAPE3U8G7gnT2RvXzNE7KwI2qjowIQc0aVgcMVlsuVcRAqdlAW
         Lv4vB8gA8rLw1eQ2vBw61EdolcVUB+9MAOrFPqJO9UP0GOrlYXYNXxoamL7fJTlIJ/lD
         Xtt4kN6iDuKC7aMcjvGzpsBD96bcF/YiOP2X9qCcozu3YqJ11CG9sakm/SgWT/XVgLq/
         BA/Go0brfkLvAvolaaw+Xju120tYwN65YqWvyCwfDdilic/bioZ1uQ5rZObdqobnebdm
         JaDD9BcuastBrA3/1ZQhglnitOFh/UA2TC+cA5uyc2zRpl2x47Qq72TgqofEGNPigH+X
         upJw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=dGdqiWPo;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d191sor520717ywa.55.2019.03.13.09.00.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 09:00:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=dGdqiWPo;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Kfs3heF+8ue5fPhJOE/1L32aZGxH5YHBEa9Vc48MxT0=;
        b=dGdqiWPo1BOx1Hrm9Yb+fmpMIctPhEyDjRuPEMfrsn/Kt3uPznTjItkUMy2bpQMkQq
         XOYyDXCPqUUbQyfrVo9hxOy8cYORZfSPejYoVDe4rwugqGjQrmP7bE6g+d4055mdv94g
         f8F56Qk5Irl6ERWKfsSoNNUIZ90EecAB46rjEJFZ6Zs/jfURwKv0AmY+pVvS8fwmIcRK
         I5RYS3nVJO4MTfBMA2OoQpzpmlWz3gRLoT0hp6pdkH6T0vjyZJRkCaaq+o5Kk3mLCC+X
         jHtDw6/k3XpwqdP0ueQ4wM2KfvFTVxbuxDX4IWvI6ywSfu9pTCyuImllQMhznFZh41Jj
         iecQ==
X-Google-Smtp-Source: APXvYqxxouOQGLIOlx87tzAbVKhhhLdCSYZWRYS4+anzMp8teZfEjVRDQ/PJhjsFB5CB1/xBLaz/JQ==
X-Received: by 2002:a81:9ad1:: with SMTP id r200mr12040290ywg.287.1552492819181;
        Wed, 13 Mar 2019 09:00:19 -0700 (PDT)
Received: from localhost ([2620:10d:c091:200::2:9a85])
        by smtp.gmail.com with ESMTPSA id q1sm5606033ywe.14.2019.03.13.09.00.18
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Mar 2019 09:00:18 -0700 (PDT)
Date: Wed, 13 Mar 2019 12:00:17 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Roman Gushchin <guroan@gmail.com>
Cc: linux-mm@kvack.org, kernel-team@fb.com, linux-kernel@vger.kernel.org,
	Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>,
	Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v2 5/6] mm: flush memcg percpu stats and events before
 releasing
Message-ID: <20190313160017.GA31891@cmpxchg.org>
References: <20190312223404.28665-1-guro@fb.com>
 <20190312223404.28665-6-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190312223404.28665-6-guro@fb.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 03:34:02PM -0700, Roman Gushchin wrote:
> Flush percpu stats and events data to corresponding before releasing
> percpu memory.
> 
> Although per-cpu stats are never exactly precise, dropping them on
> floor regularly may lead to an accumulation of an error. So, it's
> safer to flush them before releasing.
> 
> To minimize the number of atomic updates, let's sum all stats/events
> on all cpus locally, and then make a single update per entry.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Do you mind merging 6/6 into this one? That would make it easier to
verify that the code added in this patch and the code removed in 6/6
are indeed functionally equivalent.


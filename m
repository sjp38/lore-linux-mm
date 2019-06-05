Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93482C28CC5
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 13:26:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2CAE52086A
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 13:26:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="k8/Yhbuf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2CAE52086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 725186B000D; Wed,  5 Jun 2019 09:26:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D5196B000E; Wed,  5 Jun 2019 09:26:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 59CA66B0010; Wed,  5 Jun 2019 09:26:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 341896B000D
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 09:26:13 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id q26so4514364qtr.3
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 06:26:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=s6/pRA/FRv79XWIPs0xt9Lyo0lf431cIWjT6TfF1xds=;
        b=E7yzaQup+CikDOasOfIK0yhycpgr4OgblZX0UG4BrCIj/0DbHYLJUZhihRoZ0VKlGb
         J1EXW0vdI/uKP8jBpI5XrOlUVnevOxhdFMiPivQzfXkfvrVRokSYGwhIik1fuQJ/s9Yb
         qzHJBf7AwmJAjcohUQVmf3nubaQKtt/h+RWM0IAb8MIgjLylQTx93rb4qWy2LCFId4b8
         ry8ZRlRJd0yOrPEcpfWngZSVx3WbuWK3ttaSz0fOK75aUuI1R5FLODtbb/yTlRLnK1M7
         Hwg4GqR60QT6qaVKhy2h1UC8bIf7gwDF9rUgCNI0D0dnYQsrihGCcUDtOJbfApTd5OFw
         b5fQ==
X-Gm-Message-State: APjAAAUPetZfRWHMPifHdyqAxS12vKnO1vk5HRcAz2Y351Hgc56wjyLD
	7e5qP7NUcpZwuhilTZaDGH18nuaG+mkZYqd19lTEAllI4xXciKCJOwRYqXHISUuqJPdQzoNQcEQ
	1IncqefkgmPJmzeYQWqD3Kn0po3lEgrv6aP5WHAy4bzPDCOMRE7tY5Wn7sxZ04Cc=
X-Received: by 2002:ac8:156:: with SMTP id f22mr17242436qtg.58.1559741172912;
        Wed, 05 Jun 2019 06:26:12 -0700 (PDT)
X-Received: by 2002:ac8:156:: with SMTP id f22mr17242360qtg.58.1559741171886;
        Wed, 05 Jun 2019 06:26:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559741171; cv=none;
        d=google.com; s=arc-20160816;
        b=TNYMVJDO3qX1QAbhrgo5eZW9ZKaTjWF+3u/VCbjwaCmCzy5VuEmuEPlXK+/+OG09XE
         9NkC2O0a/c+o77/AwHON9apGYteRUq01QCNZXrSDpOoLfcHWRF49MzDXhsWiXh+a1aJY
         WIMOsNxfOJ9ioByQgJHXdrv94Y9TT755dM1PoR1PR0jNgNFBi0fkpilQf+Xz+U1+X2pk
         EpsD4jhzSURgkJbqF6Vo8fBDbSjaM49PyeDcoRqSQlivdXvgGasjSOLCnTV4g/azr7tn
         0XxMZg3jpboBvCNlciTIw+gtnFDiYXVLLpdfT+HFlH6KDXvXCWSn2ySHbyiusoBq30kV
         FCqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=s6/pRA/FRv79XWIPs0xt9Lyo0lf431cIWjT6TfF1xds=;
        b=JsjKD2tNpa+1R5YX+H4QZcFAUvKSZdjikixLEcU2jYer/gN8QUkXvG/9WOR44q0T3H
         H7ltFKbZc/AtUMxrPv6U7zBOQ+JNHXA/g2GlH30sKAGvxXP3owbTLX7oCQFs/6VNmsXD
         OkqSb1czk/O3LIDhpEzsh/1SP/lvdX7BRanAH8hgz+CuQH9YjOqxXcUjpicPac2XVwql
         6w7rtSYIi7NRLzM/YBOOXEIq+YyaAM5IDxoz1LuPNlkiUzaqvLNLQUpM/+lA815oHxcj
         hke+StaWaJmBblMUTdZi6aV8+8puB8NA/1trf5b1FAIzYwQSolWduxPqWIky3COqAtvi
         lzmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="k8/Yhbuf";
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n202sor4566882qka.66.2019.06.05.06.26.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Jun 2019 06:26:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="k8/Yhbuf";
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=s6/pRA/FRv79XWIPs0xt9Lyo0lf431cIWjT6TfF1xds=;
        b=k8/Yhbufqh3DMYmLycwsD4rntibzmwGLFA8f3BJkBHYziNLbAiTWTtNHG8P/LZXG01
         RQr3TuUc7en2wLHZVCPQyU8oTGqg0hN3O3VhWzUdlsZgq7nvJBBc1wHtWnsIISh87nJl
         tS4mJTrZk63Xn57xRtEf92yZctuaIVJ9RbJRB40XHVYqSOUn5EPxrnw+KvvV+eojCNNs
         26TIF/qMy/wLikOWhz0zJ0Z6oQe57wex1ly57qgu8408/ZLDG/a9ZMHgEhxIVSzHjg5G
         Ah3XhcGeFc/9gT1+wfPOSFQXBxqU9Lm38xTZvkjCj1L7OEGQRoec2kC1w/+rf8Qg82FY
         b2QQ==
X-Google-Smtp-Source: APXvYqyn/0YrgqYDxI+pyotnafRB07J91NtPSDC/hCalcKirkzsBwvMmzeYdvlDQDwYgHNmcrRVsuw==
X-Received: by 2002:a37:50d4:: with SMTP id e203mr31499108qkb.83.1559741171252;
        Wed, 05 Jun 2019 06:26:11 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:c027])
        by smtp.gmail.com with ESMTPSA id o8sm7701628qtq.18.2019.06.05.06.26.10
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 06:26:10 -0700 (PDT)
Date: Wed, 5 Jun 2019 06:26:07 -0700
From: Tejun Heo <tj@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org,
	linux-mm@kvack.org, kernel-team@fb.com
Subject: Re: [PATCH for-5.2-fixes] memcg: Don't loop on css_tryget_online()
 failure
Message-ID: <20190605132607.GI374014@devbig004.ftw2.facebook.com>
References: <20190529210617.GP374014@devbig004.ftw2.facebook.com>
 <20190605125520.GF15685@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190605125520.GF15685@dhcp22.suse.cz>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 05, 2019 at 02:55:20PM +0200, Michal Hocko wrote:
> On Wed 29-05-19 14:06:17, Tejun Heo wrote:
> > A PF_EXITING task may stay associated with an offline css.
> > get_mem_cgroup_from_mm() may deadlock if mm->owner is in such state.
> > All similar logics in memcg are falling back to root memcg on
> > tryget_online failure and get_mem_cgroup_from_mm() can do the same.
> >
> > A similar failure existed for task_get_css() and could be triggered
> > through BSD process accounting racing against memcg offlining.  See
> > 18fa84a2db0e ("cgroup: Use css_tryget() instead of css_tryget_online()
> > in task_get_css()") for details.
> > 
> > Signed-off-by: Tejun Heo <tj@kernel.org>
> 
> Do we need to mark this patch for stable or this is too unlikely to
> happen?

This one's a lot less likely than the one in task_get_css() which
already is pretty low frequency.  I don't think it warrants -stable
tagging.

Thanks.

-- 
tejun


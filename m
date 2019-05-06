Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DFCBC04A6B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 15:26:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9A8020B7C
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 15:26:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kNAXGCHs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9A8020B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7034F6B0005; Mon,  6 May 2019 11:26:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B2B66B0006; Mon,  6 May 2019 11:26:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A2226B0007; Mon,  6 May 2019 11:26:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 38E846B0005
	for <linux-mm@kvack.org>; Mon,  6 May 2019 11:26:48 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id k20so15649965qtk.13
        for <linux-mm@kvack.org>; Mon, 06 May 2019 08:26:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=uVcv5gxrx40HJxyOUvgx5wp3GUe3viewKvbzXFxWMGA=;
        b=JWrvGU1Dsnnnt1D6b+So8DSATeudWxhrvtT0Fi+nvRFj4TMwvnGu9HR0qtnh2mKICj
         KL1TJweaEU2z8s6o7gGugiM8i3Y1NXyyF+5YK0VNKESL12MxoKqmWN7C6fnOqmwtUS+1
         mIOpKSvzffZHH7O1oIDF5RzEk9+PCoblgMyb5gOx1iGEXK+y6UIoEL/dAvJjyp0shz27
         nrR4e/pKzsJXgF3WlGOkpJ7HMrqZpm510ZaiTfIewavwuhH5oaJDpIeVJES2LT+wiiEI
         3bpr1/jMx7JjWXnkaFHuTVuw+h1/PQ4bkSE/s73qkfeoysEfMd+6tk5Mrmc8md+ZDMJl
         jtSA==
X-Gm-Message-State: APjAAAUe9iCAtsSGsGKCXED7FmtiTzFOpH6DR6Xu8QbLPH8qtBzBUsrE
	M1gW7byWrLmd5WIkSzJzDFX7EqQHz5eamq5eW1RpiWQ+mE7O28w9T6LfeMXHJrpk1JtlROolz8l
	un8meQ0qlJn/ubCz5bL9XoyTUmgo1PJ5mG/7nf44Au7vo+TNOgaXeMGUc0hMpctI=
X-Received: by 2002:ac8:5188:: with SMTP id c8mr9320466qtn.262.1557156407865;
        Mon, 06 May 2019 08:26:47 -0700 (PDT)
X-Received: by 2002:ac8:5188:: with SMTP id c8mr9320414qtn.262.1557156407144;
        Mon, 06 May 2019 08:26:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557156407; cv=none;
        d=google.com; s=arc-20160816;
        b=KTjNrGvJrn6D6tI5XO5cy6imbLCkcYbX/wO3bP4a8xAiIrcq7MH9SDdMYkeIg/WMSt
         IShIVkuMpzTC5fP++KB53P6RpscmGiQOUOHIQKXyL/PN+YXFCGDQMwOW6GejAHwqwNk1
         W9w2TqVbDKlw66aceRfS2V7WiHHXUE82jgP+gfB24oN/Nc/btIzvQSd1QJn3caObtSiX
         AIjVI3i+Txg1y99syL8d3uX6X/7XwIWOQ8Fig6QynH+tOh4AGSFxlTNwFOieoZMhXt+t
         BpALSNHurGRs4OM452w0FCzPtWDRXk2lsOLEc9jFPE/QSy6vrHkLCAXfCCz2XBuE9a1c
         stoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=uVcv5gxrx40HJxyOUvgx5wp3GUe3viewKvbzXFxWMGA=;
        b=x1O4qFJLgDdTr298dsUgfOD04PIcKUlzzBzFGPsFZRCZuigL4JhRPHtm+q1V05hmw1
         uITHRCIgWyCFlcfbWBC/7E/OXVBohsS2LZIdad2RZblWE0AJ+NNKgHyl7yzWLcjdqimU
         PcG2czHami2Bz98znWKHyfe9V3ygBeej91JcvDkScfhg0msieUHZ64iaLBtP7JE2qrtu
         muEXsOlSuj5yQ/LdcnMRH7uR5v/oFU+cuQRATtXhUK0RlqKq5a/9v8JYpcJLTr96pbSn
         6hCfT35Ufms0FaYA9zy6mnWVP1xDdw9Ae5GxzU4YtK2j+RywnzMgEGvFtg3skwJgE1I/
         8V4w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kNAXGCHs;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q5sor880366qve.45.2019.05.06.08.26.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 May 2019 08:26:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kNAXGCHs;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=uVcv5gxrx40HJxyOUvgx5wp3GUe3viewKvbzXFxWMGA=;
        b=kNAXGCHsJPJnSk1S+4Hg/yKLjuRyBetqYMtBT4XmcSvlaOngptLrBWAWSQgoiqt+qq
         SlmbaADYeoYs2HfxS6UfWLFGyn8M5xuWu3n6EixHYBJ7Gbt5FyiiTq1EeX3gA8bm+vak
         jGFJgpYrd9GmbR569UqwHwe6z7q0mSq57UIqZIu1f8aKEdr+dnd2zPk9D2fuR4/HHY/M
         hdOcV1rZ8Mincs1oNYqCdEsT9K3Fx5V2Oapm7YyfGJbMXdGnDdHgrPBrWz8DZQVWxEom
         aWp1VeBzaYII8ABKROan48kPGryi+mfYPaTQxA8d9J0qvZZKV73Y2vluuRgVTcnEq0i4
         ldKQ==
X-Google-Smtp-Source: APXvYqzk+AOzpTMV+J/CSy5XKE9ZdY35ptnyEbfzsCREY2hn/LTfzkX9Rc7uiofd+Noq2KoA0jpolQ==
X-Received: by 2002:a0c:c3d0:: with SMTP id p16mr21166391qvi.229.1557156406665;
        Mon, 06 May 2019 08:26:46 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::3:34f3])
        by smtp.gmail.com with ESMTPSA id u2sm6350591qkb.37.2019.05.06.08.26.45
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 08:26:45 -0700 (PDT)
Date: Mon, 6 May 2019 08:26:43 -0700
From: Tejun Heo <tj@kernel.org>
To: Brian Welty <brian.welty@intel.com>
Cc: cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>,
	Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org,
	Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>, intel-gfx@lists.freedesktop.org,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Alex Deucher <alexander.deucher@amd.com>,
	ChunMing Zhou <David1.Zhou@amd.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 0/5] cgroup support for GPU devices
Message-ID: <20190506152643.GL374014@devbig004.ftw2.facebook.com>
References: <20190501140438.9506-1-brian.welty@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190501140438.9506-1-brian.welty@intel.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

On Wed, May 01, 2019 at 10:04:33AM -0400, Brian Welty wrote:
> The patch series enables device drivers to use cgroups to control the
> following resources within a GPU (or other accelerator device):
> *  control allocation of device memory (reuse of memcg)
> and with future work, we could extend to:
> *  track and control share of GPU time (reuse of cpu/cpuacct)
> *  apply mask of allowed execution engines (reuse of cpusets)
> 
> Instead of introducing a new cgroup subsystem for GPU devices, a new
> framework is proposed to allow devices to register with existing cgroup
> controllers, which creates per-device cgroup_subsys_state within the
> cgroup.  This gives device drivers their own private cgroup controls
> (such as memory limits or other parameters) to be applied to device
> resources instead of host system resources.
> Device drivers (GPU or other) are then able to reuse the existing cgroup
> controls, instead of inventing similar ones.

I'm really skeptical about this approach.  When creating resource
controllers, I think what's the most important and challenging is
establishing resource model - what resources are and how they can be
distributed.  This patchset is going the other way around - building
out core infrastructure for bolierplates at a significant risk of
mixing up resource models across different types of resources.

IO controllers already implement per-device controls.  I'd suggest
following the same interface conventions and implementing a dedicated
controller for the subsystem.

Thanks.

-- 
tejun


Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E288FC04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 16:52:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4452204EC
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 16:52:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lZ76QuoW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4452204EC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 53E016B0003; Thu,  9 May 2019 12:52:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 515D76B0005; Thu,  9 May 2019 12:52:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 405036B0007; Thu,  9 May 2019 12:52:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1E9DB6B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 12:52:36 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id s32so3223895qts.8
        for <linux-mm@kvack.org>; Thu, 09 May 2019 09:52:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=jUsBtZeNw5FNZWL8p+EHmLQcD3RYdpay6K7eQaM/McY=;
        b=MPFUcQ46MLWnE3wlTDia5Lv22Pi/1UcIuiBdMBpFROmlTF/S6Go1HayG2iRmuu2bsy
         iPYZLMkif9QqHquYvW4pdClFER25X4bXklTMvZ/mq1MrtVr6MAyp4p7TS9QRSaZX9M54
         sDGu9FJlVDXcYg85jraTDw09/4VQUIyhIK7VLt9zcORriLfmz6DVndVPhp5h7BdwAaDm
         zX70gr2dtU6uX++WU/A1gSjBCA/Xk2lAoOszb6WaO/PFsDGYEF/IrCV2j/fFAi4IViT/
         WZU4p5xIlNmOveazvtv1MbsAa38B0DfiXkCtfKu8eEUWIOrzMuKbsWBv7HZJZlcFTDPf
         u2vQ==
X-Gm-Message-State: APjAAAU6xKVCXOwFRQIqi1b+rrXNTUYOnJvZUpirl0l+iCDtOrD+VwBV
	5XrgBScu2ZSdBlX7/pEC/oVGbpgl1bmTWkut0CRedn5OSJ/XSjsRQvT2Q4VPzYpQsO0NahU3jhd
	/XkrwbQf2SH/J1YCIbsUfR+c6W+kT8fJc+LLAmJJbJvaEF/TrPzv7aRIoWrfayxY=
X-Received: by 2002:a0c:afd4:: with SMTP id t20mr4708311qvc.128.1557420755886;
        Thu, 09 May 2019 09:52:35 -0700 (PDT)
X-Received: by 2002:a0c:afd4:: with SMTP id t20mr4708281qvc.128.1557420755379;
        Thu, 09 May 2019 09:52:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557420755; cv=none;
        d=google.com; s=arc-20160816;
        b=o/WenYRYryCwR2COvCy3rPaTqSlV5SAu0owEXPJ4gx9ri7XIJcdJRtt0Lb+QIeAgxp
         ZDw9T1jT41o9y0ySDI0AiXLa28jDpGZSPeCYmWGRIboBgmSHQLacgXZbxf/VTyozNF7Y
         FIWDOzfg9Bh2OFW3pjjFx1IbBauQy3xw/mppY/GPBII8dO2tS2piBNB3YEKXPeaVLNm4
         b24CAMxQwdOnA0pL1/GgV28TvHVxXjDY9/oYSFvTQUDObkHkP4xR0CGerRLEUU9zG24A
         lIN84bIyEcTLNeet4967fRGMzwJ5IZTfdu/fZbe8A6GMqh0jJsMQJ9cPDd6h/HuF/emy
         i1Qw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=jUsBtZeNw5FNZWL8p+EHmLQcD3RYdpay6K7eQaM/McY=;
        b=q1OM/K0m5ONVk9OoaSsTICg2GkgwnAOnXd6m4FcF+5D+YWnxdPWK2Lh10Fb2yeUkOo
         gsHif+3SPn/za/9oPnvJWRJfmI0pk2RiXdt18zcUPWP2q86Y4oDGaEylrrrCkofKSmcS
         5lwEhJJGMSLZs3XTK5JzHWCCFZvYAfzv5kBZHFo0Md+cO7uTyHFdYPTi7cOiw80zs9XT
         0Mc9AvIT8Pxpt5u+hPWCgEtk2itMBfUDQYH9BmQkmeY57VAX/Pm7dDuj2imvT3mMtpvW
         VeLrkJvsdxyBj9z0VCuv8Sk2A2Y0K4jWo2WCCo1rbicsD/3KIGgCxwOHJgfQ3u1jT95M
         jEhg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lZ76QuoW;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n11sor3321955qtc.28.2019.05.09.09.52.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 May 2019 09:52:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lZ76QuoW;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=jUsBtZeNw5FNZWL8p+EHmLQcD3RYdpay6K7eQaM/McY=;
        b=lZ76QuoWP/RlQ75YXkOJcraYtkNTORpFzzVYzxh33URZ1VMjG3Xx5DjtZ3CHin9xa5
         fS/xGH7+lJxkoHr7QwVmyDAjbeF7nvOmxv9beDILF+sB+8CiqCfnpouLazaG1HGm4wWr
         sSEbhOG5/jozTrc/fsmtxtN959XvvWOXy5liSIq+k6J+n2dlsbSH6ap+adywXTDR7kLx
         KiqF0AAJVljqXt6esw6EBUoQy090O3TR79BAiDBzt0e3J3KThFw2L3AVAsylb2+p2P5b
         a2N9dHCQk3vpX1jSLasmI3wCY61bPxdTWmHGDEdgCCrPI+I3gdezXTWfZ9jvSdaQw7fz
         mByg==
X-Google-Smtp-Source: APXvYqx1t5kT+XXZFiBv+VqPqn8kVEYcdTa7Y4TE5pWMD/WmWnopKPh7/3rEKvsPEmRwg0IA9htZcQ==
X-Received: by 2002:ac8:19f5:: with SMTP id s50mr4695898qtk.281.1557420754955;
        Thu, 09 May 2019 09:52:34 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::1:c346])
        by smtp.gmail.com with ESMTPSA id x47sm1527214qth.68.2019.05.09.09.52.33
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 09:52:34 -0700 (PDT)
Date: Thu, 9 May 2019 09:52:32 -0700
From: Tejun Heo <tj@kernel.org>
To: "Welty, Brian" <brian.welty@intel.com>
Cc: cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>,
	Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org,
	Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>, intel-gfx@lists.freedesktop.org,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	RDMA mailing list <linux-rdma@vger.kernel.org>,
	Leon Romanovsky <leon@kernel.org>, kenny.ho@amd.com
Subject: Re: [RFC PATCH 0/5] cgroup support for GPU devices
Message-ID: <20190509165232.GW374014@devbig004.ftw2.facebook.com>
References: <20190501140438.9506-1-brian.welty@intel.com>
 <20190506152643.GL374014@devbig004.ftw2.facebook.com>
 <cf58b047-d678-ad89-c9b6-96fc6b01c1d7@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cf58b047-d678-ad89-c9b6-96fc6b01c1d7@intel.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

On Tue, May 07, 2019 at 12:50:50PM -0700, Welty, Brian wrote:
> There might still be merit in having a 'device mem' cgroup controller.
> The resource model at least is then no longer mixed up with host memory.
> RDMA community seemed to have some interest in a common controller at
> least for device memory aspects.
> Thoughts on this?   I believe could still reuse the 'struct mem_cgroup' data
> structure.  There should be some opportunity to reuse charging APIs and
> have some nice integration with HMM for charging to device memory, depending
> on backing store.

Library-ish sharing is fine but in terms of interface, I think it'd be
better to keep them separate at least for now.  Down the line maybe
these resources will interact with each other in a more integrated way
but I don't think it's a good idea to try to design and implement
resource models for something like that preemptively.

Thanks.

-- 
tejun


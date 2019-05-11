Return-Path: <SRS0=ybLw=TL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6CD0C04A6B
	for <linux-mm@archiver.kernel.org>; Sat, 11 May 2019 00:52:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 645B62184C
	for <linux-mm@archiver.kernel.org>; Sat, 11 May 2019 00:52:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nI7ojBBC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 645B62184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0FDD66B0003; Fri, 10 May 2019 20:52:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0AF386B0005; Fri, 10 May 2019 20:52:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F05E06B0006; Fri, 10 May 2019 20:52:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id D6A6C6B0003
	for <linux-mm@kvack.org>; Fri, 10 May 2019 20:52:10 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id n82so5503955iod.19
        for <linux-mm@kvack.org>; Fri, 10 May 2019 17:52:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=czZ1wMByZtzDtdrwRw90Me2/x3ZHVhQfR9+ufZ3MyKI=;
        b=K8DRG5rTazsymrUquEVTPWJxwmhrdsnW0iI0BrYRvAe8qxLPGLhdxYaEHl+L2DjP7F
         3T7RdvIin3KZ0Df5/5BquOZUZ4ikJJZ0RVmQLtP5xX9oMoq7VcabyG49u6LT2NgrB3kV
         97oaVaYRhLsP4w4AlCRkNYA7JW/X6xmxgeju+5sOWuwYdWVQlgthfvOwa8+VBjGrnO9z
         OXnXB2w2Qn1rkNX6M4NNjY2/KVBFwGmwh7OnWg9+fd/8ib4OqHPFUIQdmIZBz3rNT41v
         tV8cqP1YJraBFaUq4EgdyZ1fK/d+5xqdGcC8YHKIyuNvwg4bWlXDkbCDn1/DfzfZheaQ
         srBw==
X-Gm-Message-State: APjAAAVTgrDoWvYI7fuTVNrox1zPQtITbfCwLELGJ65K9oUHnBQzgD1q
	VhXQggR4TzlQSsMcKPYBxyHPmRGtVKboisficjTj1rGGSDa5wLY9HgC10BPg463WY/avyjkAMHA
	7+26jt9dQwwpfqy7LxhBSFYLbAoWe7UAVKQU6vbBnikN9vu/2hW/I84LDMqlAPYsIOQ==
X-Received: by 2002:a5d:8843:: with SMTP id t3mr8851720ios.102.1557535930615;
        Fri, 10 May 2019 17:52:10 -0700 (PDT)
X-Received: by 2002:a5d:8843:: with SMTP id t3mr8851689ios.102.1557535929956;
        Fri, 10 May 2019 17:52:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557535929; cv=none;
        d=google.com; s=arc-20160816;
        b=V7s3YPuQ/nS3zX6qB+w+H9scKUdT2I89ToPwyNXBYdwHLhJig+KSrNMLK08Z4tbrf7
         wRstfJQI4FSZq3lFELSCHOUT5/b3tT1Keb3NES31EGowrznX0+DxxrRMEW8KZkVB1CN+
         OwXtY4zQxXtjjy+fSh8zH+sUULz1XwxQmXjFYm4oB2iMpF1j0jGhHnNSh2iSlUskFe7q
         9WmSMtAEVLKEjGO8qi26NgXqMfeyCWaYqXoSC9sP9q23VyabsK8cZYrNHLVnqbY3qLQS
         ev9V2gP8ZCelYxrHsY7fIHTAW7FUjGlUoZsJxE+x0Yb+8wANyYxYFfMHfCio5ts3g1om
         Ry9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=czZ1wMByZtzDtdrwRw90Me2/x3ZHVhQfR9+ufZ3MyKI=;
        b=Nce7/UxIwftEbpIcQgLWUEhF3R8bJ6PEgKy4CO0MaHgQ/497+yahw4CDMylNuPicLq
         mK9AxFSw5KuoAKI+a6kzirsiHW25JGLXj+jA7ozdeko2+GIz9l9vV6OpAKOaAnIguUxu
         NBXU+IsR3wr2u/HlQ4iKHdhBDNAKYRFT+olozXd6ZOFNWKdt9UFGuKVGw8i92m1Ucrar
         GMchOj/MDUe1PaRlwyagLQIWVVU1/4uq+P0RZQF2K7gd6ye/f0R0E0j+sbIt5liO2ca9
         pJme0E5Es/LGV/wuLYH9Y5HuX+RZijb5ez9gF75QeyMHGu3fj2tUKDkwiIgNMlMj6GNm
         8pcA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nI7ojBBC;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y101sor9804808ita.6.2019.05.10.17.52.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 May 2019 17:52:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nI7ojBBC;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=czZ1wMByZtzDtdrwRw90Me2/x3ZHVhQfR9+ufZ3MyKI=;
        b=nI7ojBBCb3ByLaqMpvjW7srsk11vV8QQn1QHX3jUcSgyrlEW0sLgg2pJ77PRY8Vmh0
         bQzjz7KGQ0i/XEpPwkCk5RLWyUcWy+jd5ZGZ52DHmAVIP1n3Qwg12F/mVz+mx3BM3HY9
         fKkMMt/B6nTH+QTHPxnXoVVFqBtep3l7XLYugugkLR6cWuiAVqXeRq9KIqFiyyKX8opw
         JNLQzx5q3LIilyqVrR65pfsm4uMwo/FHTbyZSRChr36jyBNtC+6Op1I/4xr9PGthVM5w
         CZjYjyKugGKD+XCnEvOPMEu8tO267XASECi/Cqp1LJct3rJhBMhv49xkC/gLK3RDWano
         YegA==
X-Google-Smtp-Source: APXvYqwYGSeUrY2C+YJcpDQ7aETssE/Gn3rxIKZJIp0T9X4iaFOhbbcDYHufjLcmRAZ/KfgQXEDNO//LILwYM0efpg0=
X-Received: by 2002:a24:7c9:: with SMTP id f192mr10196967itf.97.1557535929747;
 Fri, 10 May 2019 17:52:09 -0700 (PDT)
MIME-Version: 1.0
References: <1554804700-7813-1-git-send-email-laoar.shao@gmail.com> <CA+q6zcVe0j7JZj8716e8CTdLDSxeE7_daRxOO9s=stWxkxGC0Q@mail.gmail.com>
In-Reply-To: <CA+q6zcVe0j7JZj8716e8CTdLDSxeE7_daRxOO9s=stWxkxGC0Q@mail.gmail.com>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Sat, 11 May 2019 08:51:33 +0800
Message-ID: <CALOAHbCptxae009VLuN4ARjobQH6L-contuW=TR9zswDirP60A@mail.gmail.com>
Subject: Re: [PATCH] mm/vmscan: expose cgroup_ino for memcg reclaim tracepoints
To: Dmitry Dolgov <9erthalion6@gmail.com>
Cc: Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux MM <linux-mm@kvack.org>, shaoyafang@didiglobal.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, May 11, 2019 at 3:21 AM Dmitry Dolgov <9erthalion6@gmail.com> wrote:
>
> > On Tue, Apr 9, 2019 at 12:12 PM Yafang Shao <laoar.shao@gmail.com> wrote:
> >
> > We can use the exposed cgroup_ino to trace specified cgroup.
>
> As far as I see, this patch didn't make it through yet, but sounds like a
> useful feature. It needs to be rebased, since mm_vmscan_memcg_reclaim_begin /
> mm_vmscan_memcg_softlimit_reclaim_begin now have may_writepage and
> classzone_idx, but overall looks good. I've checket it out with cgroup2 and
> ftrace, works as expected.

Thanks for your feedback!
I will rebase it.

Thanks
Yafang


Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 966FCC04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 19:21:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51CE1217D6
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 19:21:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RG6JA6QN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51CE1217D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF2C86B0003; Fri, 10 May 2019 15:21:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C7BC16B0005; Fri, 10 May 2019 15:21:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B1CBB6B0006; Fri, 10 May 2019 15:21:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 68B776B0003
	for <linux-mm@kvack.org>; Fri, 10 May 2019 15:21:54 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id 17so1096769lfr.14
        for <linux-mm@kvack.org>; Fri, 10 May 2019 12:21:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=t0G6g+QlT1lYek9dfa7x5K+eunPVkjOM3Q338RLnfYQ=;
        b=FmqlCTjuszPjdVPicGwjC2z4EY58OmEGxDM2RLdLDXqzUcpa27C8m8zY6R/U/9fFdE
         d4XmR2C0BuIBHOrAELZJzNskkcS07EJwsxwAVN41BuHY3XpSlnVwtHmI1GkEn+sUQAxB
         RqR1oHYo0J6huucoEx6hNO0rRuomqOHMvA9CFHYrOrD7khGB7ubcgtUt/4GLUv9rk2Lr
         c6iN6Sg82j0Mgx03diUb/X90Xgt47l1gkr5SKZrYBEi70qRQ2kuVKmUZSJN42ookCMrz
         mRn769ncG2dPXxZXd7ClkPIVfr6pk5Jai/hfAvCgd1XCq999K2cE7uLXHMQWGMiNqx/5
         ZLqA==
X-Gm-Message-State: APjAAAWFy2tJ+6gxCqwds6uGEKe8FdgRMTW4uYhtuOVOoVvV0ycmIjG7
	VYxAckxin16j+tU3Vm3RzKRW9LF++PLAXVLsmcOfeDmg5MDshfoP/Tm/dfHSNEexFQPz9JCfK0B
	zOXzK+6rFHcX8dBhlQcgaLvV44q15ej9HfpWdOon282wlqcXCXGpOmQgH9e6kZV1UuA==
X-Received: by 2002:a19:a554:: with SMTP id o81mr6880106lfe.117.1557516113643;
        Fri, 10 May 2019 12:21:53 -0700 (PDT)
X-Received: by 2002:a19:a554:: with SMTP id o81mr6880075lfe.117.1557516112722;
        Fri, 10 May 2019 12:21:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557516112; cv=none;
        d=google.com; s=arc-20160816;
        b=OgsK0u5BnfuEj2V3oy6V8P6YdqmN+Rx9TJX6qwG6L13+ZTvCkK5KXGdEyLFLwmrNO2
         4/K4NBfcmefP8RvdJBrJlcSB+mhBu6yaoAbyf6mS2oEpqu5S5O9HXobjr5oA5p/wnxbT
         rGjl/LUE8R+ksA7WBaX6hX/CB7HFfMWnOOzJX7KfQ/Jo9r9dceu5tqAL4TnzxRR+v5Y+
         W1h5o2H6DmU2suVaFfR2Mvz215kPbU6AfxowgyJpx7j1dAH66ZmEemchlyhnMhlDbp5L
         DBsUq7KcTLSkaRs/DLE6GiT064pYAd8+8dNRSC7xCu3d9dZK9wwIjfukaHlngQCTUHqc
         Dujg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=t0G6g+QlT1lYek9dfa7x5K+eunPVkjOM3Q338RLnfYQ=;
        b=Adyim9+WSPULeBjUO6Zsn0tVCMXO51dsDMSM9Jr4MdhpodtqEVAkzY7xqi/FHuUFJO
         nd71ZzXTtlyNkdhKDm4NFSLanpzqOMROpossS+NlHD3hFGAl0coLjnwseaMS5H1ozHRm
         gqbO0yN/Ri9oCqA7WiaSXnndRLzxtf/wSsYSGBHUS4nImK93O0pbaSHpf7MfZ2ckpyaJ
         CW4ajliWl8Tj4B22KHsB7H1YODDdG6yQoI7b5LamGxMs4ddzlbreoNtM3qG9bpUXsIK/
         h0CW/3g4mXJzd3lvbgGHBL2vPJdCE1vlGirrcNSp46mPxr913yHFlGXLlBm2UiHVul59
         pVgA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RG6JA6QN;
       spf=pass (google.com: domain of 9erthalion6@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=9erthalion6@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m15sor4035455ljg.18.2019.05.10.12.21.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 May 2019 12:21:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of 9erthalion6@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RG6JA6QN;
       spf=pass (google.com: domain of 9erthalion6@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=9erthalion6@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=t0G6g+QlT1lYek9dfa7x5K+eunPVkjOM3Q338RLnfYQ=;
        b=RG6JA6QNLCgv71H1icikEWlkycb3cIkJ3NL88wIenfZp2ygAPEypiPQhqtTLWt6SAr
         yglkcDF+A1NSLWYwdgddBPQTgJit3F9zivgTJdYhcyswwfzfECZ7Ltgr250d9tWbLBiY
         ucnN1rjaEESDJKQ9Jo/P0DCSM/3Y4zT+wMqDfnuJ63AV+bRWIJH8UcgbU+PhCxV2hrHF
         5emZ5/jTE2QxJt7ZPt9436bcd+MXGZ/DWth9OC1nt7aijsQQWGwYUltJ92JRO0pWVs6t
         BwfMjtJSNbzhE7Y+cv5OBaTz4RQ1YwX51uTOKbv+lyUR/8B6gzhAin+MopokYvDbnPu6
         y7EA==
X-Google-Smtp-Source: APXvYqxAgFyn5Nwf1qRQ0uRft/LbdxptYx9BG5rFGd1EQT45rdh8oLA4/0M4YfsO7p3cR2ye/pj+atkI7H96b4Hoep0=
X-Received: by 2002:a2e:96d9:: with SMTP id d25mr6598503ljj.78.1557516112248;
 Fri, 10 May 2019 12:21:52 -0700 (PDT)
MIME-Version: 1.0
References: <1554804700-7813-1-git-send-email-laoar.shao@gmail.com>
In-Reply-To: <1554804700-7813-1-git-send-email-laoar.shao@gmail.com>
From: Dmitry Dolgov <9erthalion6@gmail.com>
Date: Fri, 10 May 2019 21:24:45 +0200
Message-ID: <CA+q6zcVe0j7JZj8716e8CTdLDSxeE7_daRxOO9s=stWxkxGC0Q@mail.gmail.com>
Subject: Re: [PATCH] mm/vmscan: expose cgroup_ino for memcg reclaim tracepoints
To: Yafang Shao <laoar.shao@gmail.com>
Cc: mhocko@suse.com, akpm@linux-foundation.org, linux-mm@kvack.org, 
	shaoyafang@didiglobal.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000262, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Tue, Apr 9, 2019 at 12:12 PM Yafang Shao <laoar.shao@gmail.com> wrote:
>
> We can use the exposed cgroup_ino to trace specified cgroup.

As far as I see, this patch didn't make it through yet, but sounds like a
useful feature. It needs to be rebased, since mm_vmscan_memcg_reclaim_begin /
mm_vmscan_memcg_softlimit_reclaim_begin now have may_writepage and
classzone_idx, but overall looks good. I've checket it out with cgroup2 and
ftrace, works as expected.


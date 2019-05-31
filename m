Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2F33C04AB6
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 15:32:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ABEF326A46
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 15:32:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="YeiseFld"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ABEF326A46
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 484BE6B0278; Fri, 31 May 2019 11:32:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 435A86B027A; Fri, 31 May 2019 11:32:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 34BF66B027C; Fri, 31 May 2019 11:32:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id E07B06B0278
	for <linux-mm@kvack.org>; Fri, 31 May 2019 11:32:42 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id d18so4181232wre.22
        for <linux-mm@kvack.org>; Fri, 31 May 2019 08:32:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=fGL6EqRvLB+NZa/jkmcp3go/mVh1h/1Q1GkUa9Q/sF4=;
        b=FE6IhKqJ20Ss8DszRNBVR8DW0W0SZEDZKLPsSt/As+XlgReUM2HQQ/xwoeK0xiJ9dZ
         IMngkbhNUs3ebk4ssVz7PrJhz0b3YtIqt1fbIIMxrMj6ONva/ykcAlXxP5Le483uzPlE
         7OckkaMqqO3uQfLerjgVe34dxLS/BRP7Yzbtz0Y2qQTmD3pkVHl9YOmM7FmfsiLP0Rch
         ks9qclBVJgHNpvSFi/zU9RWD/SFomzMIL4rkozmWm5updo73WFSzzrA59C8sPqkcPcX+
         wjHxGyEyQ5aDHEW+HtcpHs0wY+QT1uTHpW7ZkrQxV8cN24HEFJVzUUjU7XiCiAc1bPdH
         IvEQ==
X-Gm-Message-State: APjAAAVr+GJbUbzwguOS7OUNCQZ6YPCOMgRdiMLZRIGJ+MASFScjhhjg
	FILiqX+POCBgu5TrMnFG5Je2MofaidQOBFtskEFLgXfW+HLqtgAhF4tWxHHBjATF9l76mfnwLJz
	ghlDnjDbtpewHDO+P9yRWiiBh31Is7tiHeIA2oDGi5nSSplwY2Gi0scvfZZwPeBE64w==
X-Received: by 2002:a5d:5302:: with SMTP id e2mr6945198wrv.347.1559316762473;
        Fri, 31 May 2019 08:32:42 -0700 (PDT)
X-Received: by 2002:a5d:5302:: with SMTP id e2mr6945159wrv.347.1559316761608;
        Fri, 31 May 2019 08:32:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559316761; cv=none;
        d=google.com; s=arc-20160816;
        b=rPuJMQlW2O1SgM9tTbMgToJpw30Teq/R4AEOQr/dgrI8aCGMz1DPTBILwx7y3mNaKv
         YFnC9j4PwkF1+ckSGNaLk/MZWMzhKaKyuntbgs2hF5MsvDjti96t/mPLvAOURhkBkJWB
         I+1l69iDND84bP4/bllba9QqcG2+h0JVXY6MqrhmwWfEg+7PfeztsNEWYBFSGUJJ54ih
         /2cC7xVtYsVOoBbgd8lxIce4kOWJxvweqWUybBBU9NWzCILPW0Bm/01jIpCUtZIw6A13
         Q8IUw/+eW12pFAvaWjYkeSs7+X0TjPZUL/DqF39237Q20HUkyGJ78p0dJlOPDO6Ihh6N
         UGZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=fGL6EqRvLB+NZa/jkmcp3go/mVh1h/1Q1GkUa9Q/sF4=;
        b=fOU43Sdcemc5rN9vxI4sVySued0sVt05mrYlidKXcK7ulZvThH5CXGi2NY7wriH6KU
         Cv4BpMgS4C93CNeSkaRgnSDP00DcV8+Dgy8E1/QqtP2YII2+E+Ye675Khjpjh1SJHAVh
         Cwp57EOtnh4BUa8ObjjwHTV788cKFDdWfIlkSPZIuCHL4JZw4BKZ66akmnsC/1+SfH7+
         KwpYymSuIIUCh0lbA1zKLsh+D8LIrlFWL/cAI7gSmChEn7Kbi3j3XF8zlrwKypBmbv0r
         aMydV+7EIExfIRTb4LUApxDRCfFdQcd00L2fFWh9mknCRqsvSlS0sPMstWo8reFT8luJ
         Feng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=YeiseFld;
       spf=pass (google.com: domain of semenzato@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=semenzato@google.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k18sor2802567wmc.21.2019.05.31.08.32.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 May 2019 08:32:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of semenzato@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=YeiseFld;
       spf=pass (google.com: domain of semenzato@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=semenzato@google.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=fGL6EqRvLB+NZa/jkmcp3go/mVh1h/1Q1GkUa9Q/sF4=;
        b=YeiseFldSN/5+crIbCEpQiudtO1RaplBzltFA4ASnVlWCmQ5W16mI5EqqeFw1Z3UKg
         chuiyCFEKBLndFf+WsXRKqU5M0jaPWk+Qo8tUXLgtYCXxT6pOezcfWx43g+SkwyNxlGp
         uMij9JgqtyU8jbzy5Mip8p9o83a0ss3Q2QaQA=
X-Google-Smtp-Source: APXvYqyNRxhqo4AWL/lfKd/hj4rWl6fa+Jp4jN534MW6jCEZuWtdLzqLwGQqfEj5trBIQEyKlzPo6lqzNySqrOsiRrk=
X-Received: by 2002:a1c:ed07:: with SMTP id l7mr5803517wmh.148.1559316760517;
 Fri, 31 May 2019 08:32:40 -0700 (PDT)
MIME-Version: 1.0
References: <20190531002633.128370-1-semenzato@chromium.org>
 <20190531060401.GA7386@dhcp22.suse.cz> <20190531062206.GD6896@dhcp22.suse.cz> <20190531062318.GE6896@dhcp22.suse.cz>
In-Reply-To: <20190531062318.GE6896@dhcp22.suse.cz>
From: Luigi Semenzato <semenzato@chromium.org>
Date: Fri, 31 May 2019 08:32:27 -0700
Message-ID: <CAA25o9TQYDCdLj-qGkwwNGDGSthX2yAtnqNWDkx-4WEe5TGxGQ@mail.gmail.com>
Subject: Re: [PATCH v2 1/1] mm: smaps: split PSS into components
To: Michal Hocko <mhocko@kernel.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Sonny Rao <sonnyrao@chromium.org>, Yu Zhao <yuzhao@chromium.org>, linux-api@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 30, 2019 at 11:23 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 31-05-19 08:22:06, Michal Hocko wrote:
> > On Fri 31-05-19 08:04:01, Michal Hocko wrote:
> > > [Please always Cc linux-api mailing list (now added) when adding a new
> > > user visible API. Keeping the rest of the email intact for reference]
> > >
> > > On Thu 30-05-19 17:26:33, semenzato@chromium.org wrote:
> > > > From: Luigi Semenzato <semenzato@chromium.org>
> > > >
> > > > Report separate components (anon, file, and shmem)
> > > > for PSS in smaps_rollup.
> > > >
> > > > This helps understand and tune the memory manager behavior
> > > > in consumer devices, particularly mobile devices.  Many of
> > > > them (e.g. chromebooks and Android-based devices) use zram
> > > > for anon memory, and perform disk reads for discarded file
> > > > pages.  The difference in latency is large (e.g. reading
> > > > a single page from SSD is 30 times slower than decompressing
> > > > a zram page on one popular device), thus it is useful to know
> > > > how much of the PSS is anon vs. file.
> >
> > Could you describe how exactly are those new counters going to be used?

Yes.  We wish to gather stats of memory usage by groups of processes
on chromebooks: various types of chrome processes, android processes
(for ARC++, i.e. android running on Chrome OS), VMs, daemons etc.  See

https://chromium.googlesource.com/chromiumos/platform2/+/refs/heads/master/metrics/pgmem.cc

and related files. The stats help us tune the memory manager better in
different scenarios.  Without this patch we only have a global
proportional RSS, but splitting into components help us deal with
situations such as a varying ratio of file vs. anon pages, which can
result, for instance, by starting/stopping android.  (In theory the
"swappiness" tunable should help with that, but it doesn't seem
effective under extreme pressure, which is unfortunately rather common
on these consumer devices).

On older kernels, which we have to support for several years, we've
added an equivalent "totmaps" locally and we'd be super-happy if going
forward we can just switch to smaps_rollup.

> > I do not expect this to add a visible penalty to users who are not going
> > to use the counter but have you tried to measure that?

Right, if smaps or smaps_rollup is not used, this cannot have a
measurable impact (maybe more code->more TLB misses, but that's at
most tiny), so no, I haven't tried to measure that.

I have been measuring the cost of smaps_rollup for all processes in a
chromebook under load (about 400 processes) but those measurements are
too noisy to show change.

The code is shared between smaps and smaps_rollup, and some of the
results aren't used in smaps, only in smaps_rollup, so there's some
waste (a couple of extra conditional branches, and loads/stores), but
again I didn't think that reducing it is worth the trouble in terms of
code complexity.

> Also forgot to mention that any change to smaps should be documented in
> Documentation/filesystems/proc.txt.

Thank you, I'll fix that and send a v3 (and Cc linux-api).


> --
> Michal Hocko
> SUSE Labs


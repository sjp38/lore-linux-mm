Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D94FEC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 08:32:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 98A9A20989
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 08:32:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 98A9A20989
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 279556B0007; Tue, 19 Mar 2019 04:32:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 228A06B0008; Tue, 19 Mar 2019 04:32:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 13EB26B000A; Tue, 19 Mar 2019 04:32:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B17316B0007
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 04:32:28 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id o9so7847780edh.10
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 01:32:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fSTdLP07PCvSMt0I5PMjiW/1dW8zYcrfjoueIXxJ4Ho=;
        b=FxgybyO3yij1/QJGs8IWLovJgCPUfArxtX8EBg/o0QOA2bQn6iZ3HkujkDTep3RMZV
         V62JpQAVXwTTSyqt57F4FcgwaycKfRSf88B+7y/IKMHwQh3GjnXuUpcXqmtnvr0HAIWR
         bwUbf765V2Q1F9zv9UjWsuGQenLv/kWcPe+p1Umn33Ik34HJrgagNAd+vRPciR+44sdn
         yYnFCJzGgn934cZ950VvnY1YgKYV1sGnjJtuFbDUTSDMx431aFqoKoksH/ZkIypksK4s
         Dmp6tJngcg59aVct3hgyB+eao2Tff4bQdsSEds1y/F5r/6Re3GfCz31Fn0j44qcjXtao
         3w+A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAUf4Da3eYyaR/CuLzclGpWpEV3Ed9mqKQ7WmkY9StPgW4ewAm8Z
	ul9iJLT7ceTZhEV4Z9kIRYb2zzk45T/VP66j2B1Xo2Bih0xGddJwpvauncmcWB6OnnN6td5bU7n
	gLzXeJ61xr21XNNtu/P1inLyDGV21XXUNiuQHubk5dUPtm/RT76gSu769WJ04tW+7OA==
X-Received: by 2002:a17:906:2781:: with SMTP id j1mr13612693ejc.238.1552984348119;
        Tue, 19 Mar 2019 01:32:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxPnmraAAi4Q2+j8ubUm26tE5rAx7FVMxEi5RlivjOQSD7GYX+fUu699BdYpsF5d7qC1t/u
X-Received: by 2002:a17:906:2781:: with SMTP id j1mr13612648ejc.238.1552984347064;
        Tue, 19 Mar 2019 01:32:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552984347; cv=none;
        d=google.com; s=arc-20160816;
        b=nJwpD4SBvGsNFpFZIdYGcCXNDvahJXYd8pHV2ptupxiulCpGWmctfg1RqLTDpCCwmo
         Mb9rMnsmZkSI45Js4BBkH9W7Kp06sPLmgZk2K7oBd9GTYNV5zxG75GH+5MMWe4pcaOpz
         1e8FJjOEmgqpV7T/DhJLCiwhAmPpcT9uF+dCecVoYDBXvZ6ySaPPqtABkyLTc25vD6UP
         hdZRuxYGuvjPjide82BCVgu+Sbo3HREmbzu/xTG94C06YQt8Ol/Qal8tZP51gX48wFr7
         DQAw2iEnET/p7a1HwXbORipSEhGJnQBgC5ndekIuSVqjY5uRIDY/f8S2S54EUxGvDzpk
         4bHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fSTdLP07PCvSMt0I5PMjiW/1dW8zYcrfjoueIXxJ4Ho=;
        b=MjA33wdmfbF+BIoglyrPDDONZ+J0e63Q9+6tfzdCcg/AC+UjmuNO9J4A00gEWVK8ja
         NEPqQFwLNCO6vYxQKeTeK2MuuNtdgMrStUIHuUakVdO4P4n0uJg93Lb57BYyalIHwf47
         GLqBwpFTiqXj6hV7Mjm3OK38LsTGrF+YjXiACisChJL76aErsyUKXBwn48iFGJwB7Fsw
         Dpza9n6Ioe6puqC0KGpZYglM0+6t4xNalY3roTIyg4uQXSIUxEsRl3yseXc2wqsRMwx7
         ES/bE2A162FuPtwOqJjiHoDOdhl/APSSis9RHuvCI4GZuqzVUD6QLfxyKSOEB2tNM637
         EKIA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s33si202216edd.306.2019.03.19.01.32.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 01:32:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 656C9AEB0;
	Tue, 19 Mar 2019 08:32:26 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id E50DA1E428E; Tue, 19 Mar 2019 09:32:25 +0100 (CET)
Date: Tue, 19 Mar 2019 09:32:25 +0100
From: Jan Kara <jack@suse.cz>
To: Kees Cook <keescook@chromium.org>
Cc: Jan Kara <jack@suse.cz>,
	syzbot <syzbot+2c49971e251e36216d1f@syzkaller.appspotmail.com>,
	Amir Goldstein <amir73il@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>, cai@lca.pw,
	Chris von Recklinghausen <crecklin@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>
Subject: Re: WARNING: bad usercopy in fanotify_read
Message-ID: <20190319083225.GB17334@quack2.suse.cz>
References: <00000000000016f7d40583d79bd9@google.com>
 <CAGXu5jKjWwYk5N3mOH1A8fXX_0BT3r1At_3MzN9M+Ckg5irKXg@mail.gmail.com>
 <20190313143503.GD9108@quack2.suse.cz>
 <CAGXu5j+_Ao_CU8DG9nrTbx5ioDkJUFw0cGcLBMWnvNLe_eFJ4A@mail.gmail.com>
 <20190313154712.GJ9108@quack2.suse.cz>
 <CAGXu5jK2cOTm=Ds_NXaCFB4i1d2d0agirHKpshy8q_2KycdnJQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jK2cOTm=Ds_NXaCFB4i1d2d0agirHKpshy8q_2KycdnJQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 18-03-19 11:27:12, Kees Cook wrote:
> On Wed, Mar 13, 2019 at 8:47 AM Jan Kara <jack@suse.cz> wrote:
> >
> > On Wed 13-03-19 08:35:33, Kees Cook wrote:
> > > On Wed, Mar 13, 2019 at 7:35 AM Jan Kara <jack@suse.cz> wrote:
> > > > On Tue 12-03-19 23:26:22, Kees Cook wrote:
> > > > > On Mon, Mar 11, 2019 at 1:42 PM syzbot
> > > > > <syzbot+2c49971e251e36216d1f@syzkaller.appspotmail.com> wrote:
> > > > > > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=17ee410b200000
> > > > > > [...]
> > > > > > ------------[ cut here ]------------
> > > > > > Bad or missing usercopy whitelist? Kernel memory exposure attempt detected
> > > > > > from SLAB object 'fanotify_event' (offset 40, size 8)!
> > > > > > [...]
> > > > > >   copy_to_user include/linux/uaccess.h:151 [inline]
> > > > > >   copy_fid_to_user fs/notify/fanotify/fanotify_user.c:236 [inline]
> > > > > >   copy_event_to_user fs/notify/fanotify/fanotify_user.c:294 [inline]
> > > > >
> > > > > Looks like this is the fh/ext_fh union in struct fanotify_fid, field
> > > > > "fid" in struct fanotify_event. Given that "fid" is itself in a union
> > > > > against a struct path, I think instead of a whitelist using
> > > > > KMEM_CACHE_USERCOPY(), this should just use a bounce buffer to avoid
> > > > > leaving a whitelist open for path or ext_fh exposure.
> > > >
> > > > Do you mean to protect it from a situation when some other code (i.e. not
> > > > copy_fid_to_user()) would be tricked into copying ext_fh containing slab
> > > > pointer to userspace?
> > >
> > > Yes. That's the design around the usercopy hardening. The
> > > "whitelisting" is either via code (with a bounce buffer, so only the
> > > specific "expected" code path can copy it), with a
> > > kmem_create_usercopy() range marking (generally best for areas that
> > > are not unions or when bounce buffers would be too big/slow), or with
> > > implicit whitelisting (via a constant copy size that cannot change at
> > > run-time, like: copy_to_user(dst, src, 6)).
> > >
> > > In this case, since there are multiple unions in place and
> > > FANOTIFY_INLINE_FH_LEN is small, it seemed best to go with a bounce
> > > buffer.
> >
> > OK, makes sense. I'll replace tha patch using kmem_create_usercopy() in my
> > tree with a variant you've suggested.
> 
> Thanks! If you're able to update the patch, it would be nice to include:
> 
> Reported-by: syzbot+2c49971e251e36216d1f@syzkaller.appspotmail.com
> Fixes: a8b13aa2 ("fanotify: enable FAN_REPORT_FID init flag")

Yeah, it's easy enough to amend the commit at this point. Done.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR


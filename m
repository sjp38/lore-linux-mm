Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0A4CC3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 08:07:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F5E822DD6
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 08:07:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="M1zV7cHa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F5E822DD6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D3306B0007; Tue, 20 Aug 2019 03:49:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 383A06B0008; Tue, 20 Aug 2019 03:49:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 272146B000A; Tue, 20 Aug 2019 03:49:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0127.hostedemail.com [216.40.44.127])
	by kanga.kvack.org (Postfix) with ESMTP id 0663E6B0007
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 03:49:57 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id A8F068419
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 07:49:57 +0000 (UTC)
X-FDA: 75842032434.26.thumb55_39ccaaebc464f
X-HE-Tag: thumb55_39ccaaebc464f
X-Filterd-Recvd-Size: 7291
Received: from mail-io1-f65.google.com (mail-io1-f65.google.com [209.85.166.65])
	by imf29.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 07:49:57 +0000 (UTC)
Received: by mail-io1-f65.google.com with SMTP id p12so7788327iog.5
        for <linux-mm@kvack.org>; Tue, 20 Aug 2019 00:49:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=8KKyQ5knFK0+9p6dVmve8R8d1JGTCXyr7UUF2b66ngc=;
        b=M1zV7cHabATce24gC8yRDeUXUL64na2h3dhqpP/rndb4anWPnfgDTcuKpZipW0KWXh
         L3MqLCMzRo0u5Yq30HEwBF9XIF5amu3X4tBRka4ed0S3VhQ6lZKe2yMYDFr8wgd6dmaI
         Ysrrg4BCEhju82jyInZTd7bj/iFRwOQNLcDE03nuw8uyc+pk6QN9cfSbjTwou0gpoEp9
         gvDXLahCpa9N/qFi4QmbdH8aIQxkmOwE9djn2vhB+3vomDRN59JKTdBQgylGl4pKOCYy
         ujpsbEj/s/QeqsRBiPAR0M9nq5xMAFU595PvL0ZTgQwtZBOLt1FK67tyfsIVUiBJny2B
         9U4w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=8KKyQ5knFK0+9p6dVmve8R8d1JGTCXyr7UUF2b66ngc=;
        b=TJoHf6tFfIHf0pwvcAOoNgq2vRAJ3QJra412HC/4fncs53j2YAqdqWirCpNzD1qA9H
         EaKNWj34IWDdAI7fwMT6RXSsdp0TtqwgqHzfQPwN3q2Imp1JXktr6DM036h4GB+2VOX1
         A1FiRl0/rZPoW7dlD0db3B8mhTZNzNxT3GMLl1M7iGY4Sz9m2Lz0nkhknY0ESPkMautJ
         QnuzZe/M9bCyuSzpijWKmCdi5B9Is/6ZZ7pKErpBWp5zPEDNFSpUTiaKlcEnZ9eqII1v
         ivo7NJ1/923Khvel/G37B0BtzzD3/fyVJjttmeR4Mstn7YENlfT7GocMYjTFEjrOZKLt
         HsKA==
X-Gm-Message-State: APjAAAW5ioR0JWUtFR9nL6JzB7wbHVccp9bJhMf6iLSFjWUOXcv8Us3f
	zn4HfssoS36kmUx5i6xB1bGPYQapqihoEhMsWyI=
X-Google-Smtp-Source: APXvYqxQaByQ/IDMh2hp46xbvXIso/P+FVgiBSxnf4dHORGIhdyPABOCHNUqyCbJnraTZajpwRY7DAiUAUjrEABmYJQ=
X-Received: by 2002:a02:4047:: with SMTP id n68mr2425984jaa.10.1566287396383;
 Tue, 20 Aug 2019 00:49:56 -0700 (PDT)
MIME-Version: 1.0
References: <1566177486-2649-1-git-send-email-laoar.shao@gmail.com>
 <20190819211200.GA24956@tower.dhcp.thefacebook.com> <CALOAHbBXoP9aypU+BzAX8cLAdYKrZ27X5JQxXBTO_oF7A4EAuA@mail.gmail.com>
 <20190820064018.GE3111@dhcp22.suse.cz> <CALOAHbA_ouCeX2HacHHpNwTY59+3tc9rOHFsz7ZgCkjXF-U72A@mail.gmail.com>
 <20190820072703.GF3111@dhcp22.suse.cz>
In-Reply-To: <20190820072703.GF3111@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 20 Aug 2019 15:49:20 +0800
Message-ID: <CALOAHbC+ByFV6tPOnkmCM9FjxP3wWnQNCWUDO6e6RaeS=Mx8_Q@mail.gmail.com>
Subject: Re: [PATCH v2] mm, memcg: skip killing processes under memcg
 protection at first scan
To: Michal Hocko <mhocko@suse.com>
Cc: Roman Gushchin <guro@fb.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, Randy Dunlap <rdunlap@infradead.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, 
	Souptick Joarder <jrdr.linux@gmail.com>, Yafang Shao <shaoyafang@didiglobal.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 3:27 PM Michal Hocko <mhocko@suse.com> wrote:
>
> On Tue 20-08-19 15:15:54, Yafang Shao wrote:
> > On Tue, Aug 20, 2019 at 2:40 PM Michal Hocko <mhocko@suse.com> wrote:
> > >
> > > On Tue 20-08-19 09:16:01, Yafang Shao wrote:
> > > > On Tue, Aug 20, 2019 at 5:12 AM Roman Gushchin <guro@fb.com> wrote:
> > > > >
> > > > > On Sun, Aug 18, 2019 at 09:18:06PM -0400, Yafang Shao wrote:
> > > > > > In the current memory.min design, the system is going to do OOM instead
> > > > > > of reclaiming the reclaimable pages protected by memory.min if the
> > > > > > system is lack of free memory. While under this condition, the OOM
> > > > > > killer may kill the processes in the memcg protected by memory.min.
> > > > > > This behavior is very weird.
> > > > > > In order to make it more reasonable, I make some changes in the OOM
> > > > > > killer. In this patch, the OOM killer will do two-round scan. It will
> > > > > > skip the processes under memcg protection at the first scan, and if it
> > > > > > can't kill any processes it will rescan all the processes.
> > > > > >
> > > > > > Regarding the overhead this change may takes, I don't think it will be a
> > > > > > problem because this only happens under system  memory pressure and
> > > > > > the OOM killer can't find any proper victims which are not under memcg
> > > > > > protection.
> > > > >
> > > > > Hi Yafang!
> > > > >
> > > > > The idea makes sense at the first glance, but actually I'm worried
> > > > > about mixing per-memcg and per-process characteristics.
> > > > > Actually, it raises many questions:
> > > > > 1) if we do respect memory.min, why not memory.low too?
> > > >
> > > > memroy.low is different with memory.min, as the OOM killer will not be
> > > > invoked when it is reached.
> > >
> > > Responded in other email thread (please do not post two versions of the
> > > patch on the same day because it makes conversation too scattered and
> > > confusing).
> > >
> > (This is an issue about time zone :-) )
>
> Normally we wait few days until feedback on the particular patch is
> settled before a new version is posted.
>
> > > Think of min limit protection as some sort of a more inteligent mlock.
> >
> > Per my perspective, it is a less inteligent mlock, because what it
> > protected may be a garbage memory.
> > As I said before, what it protected is the memroy usage, rather than a
> > specified file memory or anon memory or somethin else.
> >
> > The advantage of it is easy to use.
> >
> > > It protects from the regular memory reclaim and it can lead to the OOM
> > > situation (be it global or memcg) but by no means it doesn't prevent
> > > from the system to kill the workload if there is a need. Those two
> > > decisions are simply orthogonal IMHO. The later is a an emergency action
> > > while the former is to help guanratee a runtime behavior of the workload.
> > >
> >
> > If it can handle OOM memory reclaim, it will be more inteligent.
>
> Can we get back to an actual usecase please?
>

No real usecase.
What we concerned is if it can lead to more OOMs but can't protect
itself in OOM then this behavior seems a little wierd.
Setting oom_score_adj is another choice,  but there's no memcg-level
oom_score_adj.
memory.min is memcg-level, while oom_score_adj is process-level, that
is wierd as well.

> > > To be completely fair, the OOM killer is a sort of the memory reclaim as
> > > well so strictly speaking both mlock and memcg min protection could be
> > > considered but from any practical aspect I can think of I simply do not
> > > see a strong usecase that would justify a more complex oom behavior.
> > > People will be simply confused that the selection is less deterministic
> > > and therefore more confusing.
> > > --
> >
> > So what about ajusting the oom_socore_adj automatically when we set
> > memory.min or mlock ?
>
> oom_score_adj is a _user_ tuning. The kernel has no business in
> auto-tuning it. It should just consume the value.
>
> --
> Michal Hocko
> SUSE Labs


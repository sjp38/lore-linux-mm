Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2C81C3A5A8
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 14:59:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A722422CE3
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 14:59:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="D9ih9Cw2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A722422CE3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 114496B0003; Wed,  4 Sep 2019 10:59:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 09CE96B0006; Wed,  4 Sep 2019 10:59:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA65D6B0007; Wed,  4 Sep 2019 10:59:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0185.hostedemail.com [216.40.44.185])
	by kanga.kvack.org (Postfix) with ESMTP id C34BA6B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 10:59:44 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 5B25F82437D2
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 14:59:44 +0000 (UTC)
X-FDA: 75897547488.22.beast13_1ac186733d551
X-HE-Tag: beast13_1ac186733d551
X-Filterd-Recvd-Size: 6961
Received: from mail-pf1-f195.google.com (mail-pf1-f195.google.com [209.85.210.195])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 14:59:43 +0000 (UTC)
Received: by mail-pf1-f195.google.com with SMTP id r12so1250628pfh.1
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 07:59:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=rE1O7fdRvE37jnARAHsLuKHdyufLxZ8cmQ0gadZAgL8=;
        b=D9ih9Cw29Le6OiWtBd6aRyEWwpDTtYVafWcJb7+7LuDHHVOIIXPs+2zV1Ht8Ax++BC
         ia8+M2H3nQxG94rQvOCQVj16tbKYPYaFGu4HsuhvV78nwd2wFSOzc3c/yQNBbBvBA0Yd
         qsTZxSaf3QzMI1+NuWyOro0muhD4GtxAju2jM=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=rE1O7fdRvE37jnARAHsLuKHdyufLxZ8cmQ0gadZAgL8=;
        b=Vt+Mzy21ZxtgxnPyL2zLNZP9hBEh2ZYJp7b1HSBGogz7rGUp5IU1Y/L/FQonf5neDE
         YufiVlikvmDp293/eLCSjIBz4r3K1xJk+fjR9Kk3Anh37TnCtMF7qMn+yUs1IpIsX6FR
         wiPns27bIl5cLBANLlkFB2T6jguhktA+WKw8NNPGSDwcfgPwJnh8rNstcuyN7I9XHSV3
         7zFkGIp5z4nsbZUiq3qVB3f09wF65TT4bH5ncBCpd+14+kor9M2X8H7eBAPvS1hN8hPV
         Wu6ewYTMljVG1p5fwNHVvGfofW23Rge371rTau8+dF7LgjjG5DOnIk7unykS7J66Zo0I
         Q/BA==
X-Gm-Message-State: APjAAAVObvsWPfhnGFRpavqS+Aib5mzHbBjKlIEXL9BBtLsmBTwoKoCu
	zt7nFkpiNO9aeYqY8AVQ7B8Ijg==
X-Google-Smtp-Source: APXvYqxuEGPgataM5LlCHGmg8spcNNtos2YS2T0M6fjjvvs1uxXK1j1DXp8YMRz+T1Ekbu4SuHJDKg==
X-Received: by 2002:a17:90a:2e15:: with SMTP id q21mr5316128pjd.97.1567609182722;
        Wed, 04 Sep 2019 07:59:42 -0700 (PDT)
Received: from localhost ([2620:15c:6:12:9c46:e0da:efbf:69cc])
        by smtp.gmail.com with ESMTPSA id e6sm643717pfl.146.2019.09.04.07.59.41
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 04 Sep 2019 07:59:42 -0700 (PDT)
Date: Wed, 4 Sep 2019 10:59:41 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Daniel Colascione <dancol@google.com>
Cc: Suren Baghdasaryan <surenb@google.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Tim Murray <timmurray@google.com>,
	Carmen Jackson <carmenjackson@google.com>,
	Mayank Gupta <mayankgupta@google.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Minchan Kim <minchan@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	kernel-team <kernel-team@android.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Jerome Glisse <jglisse@redhat.com>, linux-mm <linux-mm@kvack.org>,
	Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.cz>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH v2] mm: emit tracepoint when RSS changes by threshold
Message-ID: <20190904145941.GF240514@google.com>
References: <20190903200905.198642-1-joel@joelfernandes.org>
 <CAJuCfpEXpYq2i3zNbJ3w+R+QXTuMyzwL6S9UpiGEDvTioKORhQ@mail.gmail.com>
 <CAKOZuesWV9yxbS9+T5+p1Ty1-=vFeYcHuO=6MgzTY8akMhbFbQ@mail.gmail.com>
 <20190904051549.GB256568@google.com>
 <CAKOZuet_M7nu5PYQj1iZErXV8hSZnjv4kMokVyumixVXibveoQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKOZuet_M7nu5PYQj1iZErXV8hSZnjv4kMokVyumixVXibveoQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 03, 2019 at 10:42:53PM -0700, Daniel Colascione wrote:
> On Tue, Sep 3, 2019 at 10:15 PM Joel Fernandes <joel@joelfernandes.org> wrote:
> >
> > On Tue, Sep 03, 2019 at 09:51:20PM -0700, Daniel Colascione wrote:
> > > On Tue, Sep 3, 2019 at 9:45 PM Suren Baghdasaryan <surenb@google.com> wrote:
> > > >
> > > > On Tue, Sep 3, 2019 at 1:09 PM Joel Fernandes (Google)
> > > > <joel@joelfernandes.org> wrote:
> > > > >
> > > > > Useful to track how RSS is changing per TGID to detect spikes in RSS and
> > > > > memory hogs. Several Android teams have been using this patch in various
> > > > > kernel trees for half a year now. Many reported to me it is really
> > > > > useful so I'm posting it upstream.
> > >
> > > It's also worth being able to turn off the per-task memory counter
> > > caching, otherwise you'll have two levels of batching before the
> > > counter gets updated, IIUC.
> >
> > I prefer to keep split RSS accounting turned on if it is available.
> 
> Why? AFAIK, nobody's produced numbers showing that split accounting
> has a real benefit.

I am not too sure. Have you checked the original patches that added this
stuff though? It seems to me the main win would be on big systems that have
to pay for atomic updates.

> > I think
> > discussing split RSS accounting is a bit out of scope of this patch as well.
> 
> It's in-scope, because with split RSS accounting, allocated memory can
> stay accumulated in task structs for an indefinite time without being
> flushed to the mm. As a result, if you take the stream of virtual
> memory management system calls that  program makes on one hand, and VM
> counter values on the other, the two don't add up. For various kinds
> of robustness (trace self-checking, say) it's important that various
> sources of data add up.
> 
> If we're adding a configuration knob that controls how often VM
> counters get reflected in system trace points, we should also have a
> knob to control delayed VM counter operations. The whole point is for
> users to be able to specify how precisely they want VM counter changes
> reported to analysis tools.

We're not adding more configuration knobs.

> > Any improvements on that front can be a follow-up.
> >
> > Curious, has split RSS accounting shown you any issue with this patch?
> 
> Split accounting has been a source of confusion for a while now: it
> causes that numbers-don't-add-up problem even when sampling from
> procfs instead of reading memory tracepoint data.

I think you can just disable split RSS accounting if it does not work well
for your configuration. It sounds like the problems you share are common all
with existing ways of getting RSS accounting working, and not this particular
one, hence I mentioned it is a bit of scope.

Also AFAIU, every TASK_RSS_EVENTS_THRESH the page fault code does sync the
counters. So it does not indefinitely lurk. The tracepoint's main intended
use is to detect spikes which provides ample opportunity to sync the cache.

You could reduce TASK_RSS_EVENTS_THRESH in your kernel, or even just disable
split RSS accounting if that suits you better. That would solve all the
issues you raised, not just any potential ones that you raised here for this
tracepoint.

thanks,

 - Joel




Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA3FEC41514
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 23:59:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8438B21883
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 23:59:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="fIXcKTuK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8438B21883
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 12B476B0003; Wed,  4 Sep 2019 19:59:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 103726B000E; Wed,  4 Sep 2019 19:59:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F35106B0010; Wed,  4 Sep 2019 19:59:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0110.hostedemail.com [216.40.44.110])
	by kanga.kvack.org (Postfix) with ESMTP id D215B6B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 19:59:58 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 77C77824CA32
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 23:59:58 +0000 (UTC)
X-FDA: 75898908876.07.stove37_570243354f839
X-HE-Tag: stove37_570243354f839
X-Filterd-Recvd-Size: 10721
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com [209.85.210.196])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 23:59:57 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id b13so461552pfo.8
        for <linux-mm@kvack.org>; Wed, 04 Sep 2019 16:59:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=+X0h1ts+MVZV3XmIkyVf8C7h9fPhIeM62LiNUi/8G3A=;
        b=fIXcKTuKnw1UQvuGKxVfWjVBLyghLw9pQEsEMRAmxScf17+aBm3Cvg9tH3Hv/qq4N8
         XY3oHrgvMGnbEjRBcNRLZWnoBnDDaGy8fwfMIdo47scstvvgyR5PJU9HTQSZ5XeFp3mO
         NYlWoLk6u5yQzec20/dwKo37T07QPkcJtAnlbjF6xT1SS3yepMYpGkFrSSoZ7ANWPm3u
         XHIlwi//MzAp/RUrsh/BDboGHEDtIslWQG2G4DuB5D2aQQ9eWAf9ME24K/JCMuE3dARF
         f1CewAzQ8PFVk/yA7tw5y9Cm5mTJTRUkBrTE52Dwkey+N0yzq7NFTT7QtwvXnsJmvG2W
         HUXA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=+X0h1ts+MVZV3XmIkyVf8C7h9fPhIeM62LiNUi/8G3A=;
        b=MRt/UDwNwiqbyQnqwFdYxaIZZnvrL/k/iZat4EehVeN30xlxFNIZmEQ1K9I5w50rlE
         We6gflUHk55FCKNPTGYXohkP2Jcy97yK2WB8Trc7GRZ050N1MoAmYWRlvoSnshhXPR/F
         rixWAm9d3PyphSbEhA3Ci8KgyVC9rmpHpzuOFxUduGuhMOTRF+YYhpQk50qPKhlWiSSH
         4vNmZPKh1Xm0HUs0ODkc00atswI2SdDRxFI2RfLMgCNK5dEvuCbN3iGCeou7a3v6Gf7D
         5omcXwFzSdPYJOKbNn6QICmbALHv+yTRlt1KWDKaN6QdDt3ewYUxglRmSDCngF4bPmXH
         ugCA==
X-Gm-Message-State: APjAAAWcQnS17ryEyluz482Upl+YmsWM5SPL62CVDk6ycT+lwWQRIyMN
	8l/vj6dXzRzrBvBvtXwGLxNLuA==
X-Google-Smtp-Source: APXvYqyEWakNdGwZHc9tgEvaXh3mgZ+5G0M2yH3pF4rpPHtMAxCZpiCY2+Z+EgCxeLIppsp6X/hLYQ==
X-Received: by 2002:aa7:8251:: with SMTP id e17mr356053pfn.189.1567641596235;
        Wed, 04 Sep 2019 16:59:56 -0700 (PDT)
Received: from sspatil-glaptop2.roam.corp.google.com (96-90-215-179-static.hfc.comcastbusiness.net. [96.90.215.179])
        by smtp.gmail.com with ESMTPSA id k14sm214018pgi.20.2019.09.04.16.59.54
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 04 Sep 2019 16:59:55 -0700 (PDT)
Date: Wed, 4 Sep 2019 16:59:53 -0700
From: sspatil@google.com
To: dancol@google.com, joel@joelfernandes.org, surenb@google.com,
 linux-kernel@vger.kernel.org, timmurray@google.com, carmenjackson@google.com,
 mayankgupta@google.com, rostedt@goodmis.org, minchan@kernel.org,
 akpm@linux-foundation.org, kernel-team@android.com, aneesh.kumar@linux.ibm.com,
 dan.j.williams@intel.com, jglisse@redhat.com, linux-mm@kvack.org,
 willy@infradead.org, mhocko@suse.cz, rcampbell@nvidia.com, vbabka@suse.cz,
 sspatil+mutt@google.com
Cc: Joel Fernandes <joel@joelfernandes.org>,
 Suren Baghdasaryan <surenb@google.com>,
 LKML <linux-kernel@vger.kernel.org>, Tim Murray <timmurray@google.com>,
 Carmen Jackson <carmenjackson@google.com>,
 Mayank Gupta <mayankgupta@google.com>,
 Steven Rostedt <rostedt@goodmis.org>, Minchan Kim <minchan@kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 kernel-team <kernel-team@android.com>,
 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
 Dan Williams <dan.j.williams@intel.com>,
 Jerome Glisse <jglisse@redhat.com>, linux-mm <linux-mm@kvack.org>,
 Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.cz>,
 Ralph Campbell <rcampbell@nvidia.com>, Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH v2] mm: emit tracepoint when RSS changes by threshold
Message-ID: <20190904235953.GH14859@google.com>
References: <20190903200905.198642-1-joel@joelfernandes.org>
 <CAJuCfpEXpYq2i3zNbJ3w+R+QXTuMyzwL6S9UpiGEDvTioKORhQ@mail.gmail.com>
 <CAKOZuesWV9yxbS9+T5+p1Ty1-=vFeYcHuO=6MgzTY8akMhbFbQ@mail.gmail.com>
 <20190904051549.GB256568@google.com>
 <CAKOZuet_M7nu5PYQj1iZErXV8hSZnjv4kMokVyumixVXibveoQ@mail.gmail.com>
 <20190904145941.GF240514@google.com>
 <CAKOZuevvgANuaZc9P09=+tcM5MasPPvpkVmWf8wucsnVpdY8mg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKOZuevvgANuaZc9P09=+tcM5MasPPvpkVmWf8wucsnVpdY8mg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 04, 2019 at 10:15:10AM -0700, 'Daniel Colascione' via kernel-team wrote:
> On Wed, Sep 4, 2019 at 7:59 AM Joel Fernandes <joel@joelfernandes.org> wrote:
> >
> > On Tue, Sep 03, 2019 at 10:42:53PM -0700, Daniel Colascione wrote:
> > > On Tue, Sep 3, 2019 at 10:15 PM Joel Fernandes <joel@joelfernandes.org> wrote:
> > > >
> > > > On Tue, Sep 03, 2019 at 09:51:20PM -0700, Daniel Colascione wrote:
> > > > > On Tue, Sep 3, 2019 at 9:45 PM Suren Baghdasaryan <surenb@google.com> wrote:
> > > > > >
> > > > > > On Tue, Sep 3, 2019 at 1:09 PM Joel Fernandes (Google)
> > > > > > <joel@joelfernandes.org> wrote:
> > > > > > >
> > > > > > > Useful to track how RSS is changing per TGID to detect spikes in RSS and
> > > > > > > memory hogs. Several Android teams have been using this patch in various
> > > > > > > kernel trees for half a year now. Many reported to me it is really
> > > > > > > useful so I'm posting it upstream.
> > > > >
> > > > > It's also worth being able to turn off the per-task memory counter
> > > > > caching, otherwise you'll have two levels of batching before the
> > > > > counter gets updated, IIUC.
> > > >
> > > > I prefer to keep split RSS accounting turned on if it is available.
> > >
> > > Why? AFAIK, nobody's produced numbers showing that split accounting
> > > has a real benefit.
> >
> > I am not too sure. Have you checked the original patches that added this
> > stuff though? It seems to me the main win would be on big systems that have
> > to pay for atomic updates.
> 
> I looked into this issue the last time I mentioned split mm
> accounting. See [1]. It's my sense that the original change was
> inadequately justified; Michal Hocko seems to agree. I've tried
> disabling split rss accounting locally on a variety of systems ---
> Android, laptop, desktop --- and failed to notice any difference. It's
> possible that some difference appears at a scale beyond that to which
> I have access, but if the benefit of split rss accounting is limited
> to these cases, split rss accounting shouldn't be on by default, since
> it comes at a cost in consistency.
> 
> [1] https://lore.kernel.org/linux-mm/20180227100234.GF15357@dhcp22.suse.cz/
> 
> > > > I think
> > > > discussing split RSS accounting is a bit out of scope of this patch as well.
> > >
> > > It's in-scope, because with split RSS accounting, allocated memory can
> > > stay accumulated in task structs for an indefinite time without being
> > > flushed to the mm. As a result, if you take the stream of virtual
> > > memory management system calls that  program makes on one hand, and VM
> > > counter values on the other, the two don't add up. For various kinds
> > > of robustness (trace self-checking, say) it's important that various
> > > sources of data add up.
> > >
> > > If we're adding a configuration knob that controls how often VM
> > > counters get reflected in system trace points, we should also have a
> > > knob to control delayed VM counter operations. The whole point is for
> > > users to be able to specify how precisely they want VM counter changes
> > > reported to analysis tools.
> >
> > We're not adding more configuration knobs.
> 
> This position doesn't seem to be the thread consensus yet.
> 
> > > > Any improvements on that front can be a follow-up.
> > > >
> > > > Curious, has split RSS accounting shown you any issue with this patch?
> > >
> > > Split accounting has been a source of confusion for a while now: it
> > > causes that numbers-don't-add-up problem even when sampling from
> > > procfs instead of reading memory tracepoint data.
> >
> > I think you can just disable split RSS accounting if it does not work well
> > for your configuration.
> 
> There's no build-time configuration for split RSS accounting. It's not
> reasonable to expect people to carry patches just to get their memory
> usage numbers to add up.

sure, may be send a patch to make one in that case or for deleting the split
RSS accounting code like you said below.

> 
> > Also AFAIU, every TASK_RSS_EVENTS_THRESH the page fault code does sync the
> > counters. So it does not indefinitely lurk.
> 
> If a thread incurs TASK_RSS_EVENTS_THRESH - 1 page faults and then
> sleeps for a week, all memory counters observable from userspace will
> be wrong for a week. Multiply this potential error by the number of
> threads on a typical system and you have to conclude that split RSS
> accounting produces a lot of potential uncertainty. What are we
> getting in exchange for this uncertainty?
> 
> > The tracepoint's main intended
> > use is to detect spikes which provides ample opportunity to sync the cache.
> 
> The intended use is measuring memory levels of various processes over
> time, not just detecting "spikes". In order to make sense of the
> resulting data series, we need to be able to place error bars on it.
> The presence of split RSS accounting makes those error bars much
> larger than they have to be.
> 
> > You could reduce TASK_RSS_EVENTS_THRESH in your kernel, or even just disable
> > split RSS accounting if that suits you better. That would solve all the
> > issues you raised, not just any potential ones that you raised here for this
> > tracepoint.
> 
> I think we should just delete the split RSS accounting code unless
> someone can demonstrate that it's a measurable win on a typical
> system. The first priority of any system should be correctness.
> Consistency is a kind of correctness. Departures from correctness
> coming only from quantitatively-justifiable need.

I think you make some good points for correctness, but I still don't see
how all that relates to _this_ change. We currently do want an ability to get
these rss spikes in the traces (as the patch description shows).

You seem to be arguing about the correctness of split RSS accounting. I would
suggest to send a patch to delete the split RSS accounting code and take
these *very valid* arguments there? I am struggling to see the point of
derailing this _specific_ change for that.

- ssp

> 
> -- 
> To unsubscribe from this group and stop receiving emails from it, send an email to kernel-team+unsubscribe@android.com.
> 


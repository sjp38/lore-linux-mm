Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5347C4321A
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 21:25:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65C482146E
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 21:25:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65C482146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D1036B0005; Thu, 27 Jun 2019 17:25:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 082918E0003; Thu, 27 Jun 2019 17:25:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8AB88E0002; Thu, 27 Jun 2019 17:25:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B2D286B0005
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 17:25:35 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id b195so1952742pfb.3
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 14:25:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mcIz0jVRYTUruhG/KoFDVf1SI7yQGass2g5eWReCXuc=;
        b=ea3Qndn2gkKmrSBysTYwj/uRv7ayq89JjaO+Dpp7cQYCmDR0UbnrLAGmG3fI/+z/99
         WLBbfbZOUUjiMokWVyzlRWQCOhAUt7G/VsTAnn1dZpox/QPFNmEgDY74p7RVLK1QQs9E
         A025gV+kYICdZLwPn9eQXHwrzt5BbI5eznUKbq9Z1n5U2ClHPb45CKVa6xIF05ZUwbJF
         JT7mcF7a7oJ6RVnUWOEW47Dy1aQiJ+Os2FWZLS400yNne1qCei2z/7j/FhLY58W7hcCO
         Ag3raLk8yVTysTJnu5DICz3MSrLvPOGMZKhHoBUgrbtsI/jqIQfQpWPQ0wxrF5ZUCd+c
         QtGw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mcgrof@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mcgrof@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAV9voOIe05bg1kD5/8FVeafQbLw1qmX2CkvMAj7IjMfcoxgmkB9
	gfE3FEWBN6Q/laFSWZ0P/n+u1gOsUkHuzb1BdXHsHixeXUEV+/nXDhSeQ264kkq2v749jV2uZnh
	KI4Lfbg/UkZTg3d7dpSbGDJOmVJ34PAHBqQoLR0Tuj8B40E1/OAnctZ7vshG9kE8=
X-Received: by 2002:a17:90a:b30a:: with SMTP id d10mr8721373pjr.8.1561670735337;
        Thu, 27 Jun 2019 14:25:35 -0700 (PDT)
X-Received: by 2002:a17:90a:b30a:: with SMTP id d10mr8721313pjr.8.1561670734415;
        Thu, 27 Jun 2019 14:25:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561670734; cv=none;
        d=google.com; s=arc-20160816;
        b=XDo7+b7QNNge3lV5k5g259n6zHExDgbDIGNWNy2nKml29g2hamnwrKyh4em9scUPRO
         J2ZJOLWx26HDx/m+7a9bZnyGMbUob3F1mE6ZPLoaVb6J5K4FDTQVjYzMqXqqETQkQVDo
         Y/UIPK9u1Kf6Deyc7MdmMEdkrqy4M5tI6yHLainUqntfGuahBWOuqA0W8Ut9vNSZNeRO
         VE8+sxd9qHFM4RhmJ601fAwo0VLMCn5ikQ88F6D7Tfa/erlaKwIoW4oid3EaiM0jWc6o
         urM21Obr7cf2M4lbTN73LMcswBb5lYy157NJ+Rpcim6rbD2YOpk0vvyrfs9Wrs/SJS7R
         EfnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=mcIz0jVRYTUruhG/KoFDVf1SI7yQGass2g5eWReCXuc=;
        b=CLp/Sh5keGMw902A4Httg60yBLF+EAqw7r7+h2mFb3WlqAM1q/qkjWSUBYIJQdrogB
         yXWM6QZoOdNv3il6+/mp2qGRFWxmVCD3cXjAoydpoJM+RsLHVOg5uQIymVYaYe3HeK5s
         evlgHFnAO6bY5XQ610SnvuNmEsKmPrFTXipqCP0vDS0ij6VlPjIFdLTnV4meC1e5dI7U
         4iV58V0nM6ju33A0TggNSQSCl8umPL8O29vm84ulF38wW4pG4ejKjCancG3KoVCTGoL5
         PMDo4uJg5v1b9A4+usu01r4Wkieneh+35SU5x8sMmZ/RG4EABa2k2hXVu49gQoQbBf7R
         Uxsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mcgrof@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mcgrof@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d7sor47677pfq.35.2019.06.27.14.25.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 14:25:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of mcgrof@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mcgrof@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mcgrof@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqyGsCu1nPJ5bWmdfsOj/NIWWCfOB1DP91SvS5iulJBr8pRy1i6aED362EmiH8cSwbKJ5LuQ2w==
X-Received: by 2002:a65:538d:: with SMTP id x13mr5857316pgq.190.1561670733735;
        Thu, 27 Jun 2019 14:25:33 -0700 (PDT)
Received: from 42.do-not-panic.com (42.do-not-panic.com. [157.230.128.187])
        by smtp.gmail.com with ESMTPSA id a25sm41703pfn.1.2019.06.27.14.25.32
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 27 Jun 2019 14:25:32 -0700 (PDT)
Received: by 42.do-not-panic.com (Postfix, from userid 1000)
	id DF854403ED; Thu, 27 Jun 2019 21:25:31 +0000 (UTC)
Date: Thu, 27 Jun 2019 21:25:31 +0000
From: Luis Chamberlain <mcgrof@kernel.org>
To: Waiman Long <longman@redhat.com>,
	Masami Hiramatsu <mhiramat@redhat.com>,
	Masoud Asgharifard Sharbiani <masouds@google.com>
Cc: Roman Gushchin <guro@fb.com>, Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"cgroups@vger.kernel.org" <cgroups@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Shakeel Butt <shakeelb@google.com>,
	Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/2] mm, slab: Extend vm/drop_caches to shrink kmem slabs
Message-ID: <20190627212531.GF19023@42.do-not-panic.com>
References: <20190624174219.25513-1-longman@redhat.com>
 <20190624174219.25513-3-longman@redhat.com>
 <20190626201900.GC24698@tower.DHCP.thefacebook.com>
 <063752b2-4f1a-d198-36e7-3e642d4fcf19@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <063752b2-4f1a-d198-36e7-3e642d4fcf19@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 27, 2019 at 04:57:50PM -0400, Waiman Long wrote:
> On 6/26/19 4:19 PM, Roman Gushchin wrote:
> >>  
> >> +#ifdef CONFIG_MEMCG_KMEM
> >> +static void kmem_cache_shrink_memcg(struct mem_cgroup *memcg,
> >> +				    void __maybe_unused *arg)
> >> +{
> >> +	struct kmem_cache *s;
> >> +
> >> +	if (memcg == root_mem_cgroup)
> >> +		return;
> >> +	mutex_lock(&slab_mutex);
> >> +	list_for_each_entry(s, &memcg->kmem_caches,
> >> +			    memcg_params.kmem_caches_node) {
> >> +		kmem_cache_shrink(s);
> >> +	}
> >> +	mutex_unlock(&slab_mutex);
> >> +	cond_resched();
> >> +}
> > A couple of questions:
> > 1) how about skipping already offlined kmem_caches? They are already shrunk,
> >    so you probably won't get much out of them. Or isn't it true?
> 
> I have been thinking about that. This patch is based on the linux tree
> and so don't have an easy to find out if the kmem caches have been
> shrinked. Rebasing this on top of linux-next, I can use the
> SLAB_DEACTIVATED flag as a marker for skipping the shrink.
> 
> With all the latest patches, I am still seeing 121 out of a total of 726
> memcg kmem caches (1/6) that are deactivated caches after system bootup
> one of the test systems. My system is still using cgroup v1 and so the
> number may be different in a v2 setup. The next step is probably to
> figure out why those deactivated caches are still there.
> 
> > 2) what's your long-term vision here? do you think that we need to shrink
> >    kmem_caches periodically, depending on memory pressure? how a user
> >    will use this new sysctl?
> Shrinking the kmem caches under extreme memory pressure can be one way
> to free up extra pages, but the effect will probably be temporary.
> > What's the problem you're trying to solve in general?
> 
> At least for the slub allocator, shrinking the caches allow the number
> of active objects reported in slabinfo to be more accurate. In addition,
> this allow to know the real slab memory consumption. I have been working
> on a BZ about continuous memory leaks with a container based workloads.

So.. this is still a work around?

> The ability to shrink caches allow us to get a more accurate memory
> consumption picture. Another alternative is to turn on slub_debug which
> will then disables all the per-cpu slabs.

So this is a debugging mechanism?

> Anyway, I think this can be useful to others that is why I posted the patch.

Since this is debug stuff, please add this to /proc/sys/debug/ instead.
That would reflect the intention, and would avoid the concern that folks
in production would use these things.

Since we only have 2 users of /proc/sys/debug/ I am now wondering if
would be best to add a new sysctl debug taint flag. This way bug
reports with these stupid knobs can got to /dev/null inbox for bug
reports.

Masami, /proc/sys/debug/kprobes-optimization is debug. Would you be OK
to add the taint for it too?

Masoud, /proc/sys/debug/exception-trace seems to actually be enabled
by default, and its goal seems to be to enable disabling it. So I
don't think it would make sense to taint there.

So.. maybe we need something /proc/sys/taints/ or
/proc/sys/debug/taints/ so its *very* clear this is by no way ever
expected to be used in production.

May even be good to long term add a symlink for vm/drop_caches there
as well?

  Luis


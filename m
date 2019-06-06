Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4A7AC04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 19:20:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E72B2089E
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 19:20:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="Go+h0Qnn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E72B2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05CD16B027B; Thu,  6 Jun 2019 15:20:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00E1F6B027C; Thu,  6 Jun 2019 15:20:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3D546B027D; Thu,  6 Jun 2019 15:20:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id C2CE76B027B
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 15:20:03 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id t196so2886447qke.0
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 12:20:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=NOvZLPRSrzGWhPhtd8eWwTAdoG6UOPdllDEIeYGVWVY=;
        b=rZ/rg+dnwP6DIgOdQ53KOu0pj7YxokThP4MvWO8m2JQjL9ZONJNLDBSdaL02R+2UhU
         XlkqTyymg2nECqp0sSl5wbfcPg50OU8WHVXb/8XxKV+ZIA5C5Uglh8KwwJAP94Z0ns8M
         VMrDBzIj/lXubMTZ52UDN5Bcg+eaNYP50D8TnpC6RKl2remk9MDWj9ukXaRjdxn9+CHc
         +tc7Hrlnt7Co2iETZ/ClbUXEG7F2k9Bzp6w5ce2HLsGHfi8b+cOrB96dZyTO2/FcnZAL
         SHbdOjSPpAWCcBEIwsua86lOIdzOnsduYiVv+ev4C2XJpWjtFB5hQPdNwnMQQTGPUop6
         wTJg==
X-Gm-Message-State: APjAAAVMJ9zVn8OZLkygBKsVSDJYPLlFJf7EhZhgalwISlo3nzpwU1FR
	EvFOaRvxBmr8cOg8+BLWKpPMCN59JC2hbbg63Q8QKh1F5W07K2LsyzgyTcYylfTMMKfRz+y0qty
	vuUyktrUsnVD2VJ8Bw/ugnGv/CR/3YbvGgBbThtdOGQwkVryGG157fH6lMSUgZCDEQQ==
X-Received: by 2002:a37:2f87:: with SMTP id v129mr21824545qkh.151.1559848803532;
        Thu, 06 Jun 2019 12:20:03 -0700 (PDT)
X-Received: by 2002:a37:2f87:: with SMTP id v129mr21824503qkh.151.1559848802938;
        Thu, 06 Jun 2019 12:20:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559848802; cv=none;
        d=google.com; s=arc-20160816;
        b=e+Baktw2mPm8h31/k1degwCdSinqBKoQtFgfPnBf6+9hYA0jHE2WbctJp1p+S5wWcV
         z9wDO/mheLNonb8QwYByrpDXcO/o2ti+VPnaaIgUErUk0nL7nqF2N84rbr6xVVCiNFxm
         PaJTCrL/UGk0PMBglsasBn8g1MPgnQ9wLfZ0YOzPmHp8aHkHKp27Jf33TGurEDKPkbx5
         503AGr4ogwn/d53XLpOkAUPF7Nuw/fXmE6K5q/f798QkzmwLuROvnlPFF4MYeA476ocB
         AKC72UtpSEd1ovDRTp1d0iPEpf75GflArLhvSwyr9DrMoYESAwLQoDjYK4OoqS8ulxoA
         fWhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=NOvZLPRSrzGWhPhtd8eWwTAdoG6UOPdllDEIeYGVWVY=;
        b=sZNX3FygfMtyZCQ9+4ZqRzO546yVk6MWdjN3lv1OOAbE774GsUI6LSwFjMwH4GYFxz
         asQvPSl08cpuILLnwPFSBPs6l72AvA7EYjjlmkAjOfoewILfohGO06m0D5cCI3JRDo+Y
         qL82sjLc04SHZbuwxo99vuouVhzJSfEaHcDGTr1r9t7XlhsrQrEsaCLrSde2Whfb0Qte
         gt/LPNt2anUpN82NK6NK1Vg+kifXg7V8Wk1HfbW6UAKRcKfeax4Ih+Ool75FA+seECCP
         iJyjgJe1h/eR9PaVspgATwjO12q3JUxrb7HNqLdtxyUHkYYH5o0FyUC8tmuxd294hola
         Ov3g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Go+h0Qnn;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p3sor2123116qvs.34.2019.06.06.12.20.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 12:20:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Go+h0Qnn;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=NOvZLPRSrzGWhPhtd8eWwTAdoG6UOPdllDEIeYGVWVY=;
        b=Go+h0QnnbPbmbQnaHLoeVDVfIeog+XU4T/7TDtX4Srl9uVBh+7+iupfn9qMIilwXnJ
         QD6DfGl4m7HDtXQfWSl+2Bg9kX/Mj+fUzCOhJVKNK1l6SJOqD+4a0MesPwpeZ9jVym2M
         ZukM+UEQ2DoBQqS8aFwKMRS/UyLpudOplbAsjTb8XBZNkciK7qUPL38Egl4YT7FZxWhg
         ktmOeD2UiTIbD7Vy40kegb6Fgix+8J39uqPzpRtGNHYbin8QxIXY27pwkj/vlXzC3xFs
         AVtQAI1EyiO2prRqha0arX4q7pAVcyZU401kmc4b/OhezyWoChXH933z9Z9+dGnsrME5
         ptOw==
X-Google-Smtp-Source: APXvYqyxYoNhsdYVBBxjYNi54BLNBE5mbbC0g0zhB9xE8cJnmhy61aNq31c4sszODb5OeOKktoDvVA==
X-Received: by 2002:a0c:b095:: with SMTP id o21mr12310027qvc.73.1559848802623;
        Thu, 06 Jun 2019 12:20:02 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id a11sm13209qkn.26.2019.06.06.12.20.01
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Jun 2019 12:20:01 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hYxvd-0008WS-Ew; Thu, 06 Jun 2019 16:20:01 -0300
Date: Thu, 6 Jun 2019 16:20:01 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: "Kuehling, Felix" <Felix.Kuehling@amd.com>
Cc: "alex.deucher@amd.com" <alex.deucher@amd.com>,
	"airlied@gmail.com" <airlied@gmail.com>,
	"jglisse@redhat.com" <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>
Subject: Re: [PATCH 0/2] Two bug-fixes for HMM
Message-ID: <20190606192001.GE17373@ziepe.ca>
References: <20190510195258.9930-1-Felix.Kuehling@amd.com>
 <20190606151149.GA5506@ziepe.ca>
 <1d309300-41d8-eb31-38c2-c6c9dd5c0ba8@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1d309300-41d8-eb31-38c2-c6c9dd5c0ba8@amd.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 07:04:46PM +0000, Kuehling, Felix wrote:
> On 2019-06-06 11:11 a.m., Jason Gunthorpe wrote:
> > On Fri, May 10, 2019 at 07:53:21PM +0000, Kuehling, Felix wrote:
> >> These problems were found in AMD-internal testing as we're working on
> >> adopting HMM. They are rebased against glisse/hmm-5.2-v3. We'd like to get
> >> them applied to a mainline Linux kernel as well as drm-next and
> >> amd-staging-drm-next sooner rather than later.
> >>
> >> Currently the HMM in amd-staging-drm-next is quite far behind hmm-5.2-v3,
> >> but the driver changes for HMM are expected to land in 5.2 and will need to
> >> be rebased on those HMM changes.
> >>
> >> I'd like to work out a flow between Jerome, Dave, Alex and myself that
> >> allows us to test the latest version of HMM on amd-staging-drm-next so
> >> that ideally everything comes together in master without much need for
> >> rebasing and retesting.
> > I think we have that now, I'm running a hmm.git that is clean and can
> > be used for merging into DRM related trees (and RDMA). I've commited
> > to send this tree to Linus at the start of the merge window.
> >
> > See here:
> >
> >   https://lore.kernel.org/lkml/20190524124455.GB16845@ziepe.ca/
> >
> > The tree is here:
> >
> >   https://git.kernel.org/pub/scm/linux/kernel/git/rdma/rdma.git/log/?h=hmm
> >
> > However please consult with me before making a merge commit to be
> > co-ordinated. Thanks
> >
> > I see in this thread that AMDGPU missed 5.2 beacause of the
> > co-ordination problems this tree is intended to solve, so I'm very
> > hopeful this will help your work move into 5.3!
> 
> Thanks Jason. Our two patches below were already included in the MM tree 
> (https://ozlabs.org/~akpm/mmots/broken-out/). With your new hmm.git, 
> does that mean HMM fixes and changes will no longer go through Andrew 
> Morton but directly through your tree to Linus?

I belive so, that is what we agreed to in the RFC. At least for this
cycle.

I already noticed the duplication and sent Andrew a separate note..

It will be best if most of the things touching mm/hmm.c go to hmm.git
to avoid conflicts for Linus.

> We have also applied the two patches to our internal tree which is 
> currently based on 5.2-rc1 so we can make progress.

Makes sense, this is is also why this shared tree should be very
helpful..

I intend to run it as a clean and stable non-rebasing tree, ah
probably starting tomorrow since I see there is still another
fixup. :)

> Alex, I think merging hmm would be an extra step every time you rebase
> amd-staging-drm-next. We could probably also merge hmm at other times as
> needed. Do you think this would cause trouble or confusion for 
> upstreaming through drm-next?

I'm not sure what the workflow the amd tree uses, but..

Broadly: If the AMD tree is rebasing then likely you can simply rebase
your AMD tree on top of hmm.git (or maybe hmm.git merge'd into
DRM).

Most likely we will want to send a PR for hmm.git to main DRM tree
prior to merging AMD's tree, but I'm also rather relying on DRM folks
to help build the workflow they want in their world..

There are quite a few options depending on people's preferences and
workflow.

Thanks,
Jason


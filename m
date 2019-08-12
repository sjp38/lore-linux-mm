Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_2
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 802A1C31E40
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 16:09:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 339FC206A2
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 16:09:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="rM4BK921"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 339FC206A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DAD996B0006; Mon, 12 Aug 2019 12:09:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D5DBD6B0007; Mon, 12 Aug 2019 12:09:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C26026B0008; Mon, 12 Aug 2019 12:09:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0002.hostedemail.com [216.40.44.2])
	by kanga.kvack.org (Postfix) with ESMTP id 9B5EF6B0006
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 12:09:13 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 4575655F85
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 16:09:13 +0000 (UTC)
X-FDA: 75814260186.24.fuel96_16327db1bcc45
X-HE-Tag: fuel96_16327db1bcc45
X-Filterd-Recvd-Size: 7524
Received: from mail-qt1-f193.google.com (mail-qt1-f193.google.com [209.85.160.193])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 16:09:12 +0000 (UTC)
Received: by mail-qt1-f193.google.com with SMTP id b11so3553465qtp.10
        for <linux-mm@kvack.org>; Mon, 12 Aug 2019 09:09:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=jnaZNj6OcIrJnBFWcRbWSkY4xvepDmg4dEtDDEvjaC0=;
        b=rM4BK921mK8jKTrz9MbRlgFiOPaChAQ15XigvY/jAwEMMmDjYs+frqzS9w0lCcBJ2y
         LGHmgem/txYDZlL6lL1NndLexe2xsTsATmLxsr1ZR6w/ArOF8I+GYdm5k4I4zt4w8d9m
         4B/bfXraf5DMKa6mheJn03H+NfDgHpFJEo4P7dUZ1UI81eKjI2XkWslh07PPm1Igq83k
         S4rnb5ZrF04v9S0JYjHJyPaZ/tsGcqfmski9/9jrIBiLvPgz24cpRvO9W2N3xQlgGKZB
         2sgoRt+hNct+yDOozBW3wK30nlZ3XJ1XyvHVscTMM4skUtmNFIOOphCzkMVN+2ykIxiW
         YP2g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=jnaZNj6OcIrJnBFWcRbWSkY4xvepDmg4dEtDDEvjaC0=;
        b=YvmpHtOb2XOc9IeJ2fo0CD1523tMAavAsajZK1kF0erDl7u2nD18MUnXuyEUWkxa+A
         Dkfutz9bs3C2aQom7B/+fhweT0NgzqbtS0r2qNRiXliirVIhHXSL+/uVyuW5Mt2ynYx+
         G2sZAXb/AJsYy1YR+10UEcEvoDDyqYfp4sxMtmPc58VfT763YtgcGUF5AsUqWgZVdZzI
         A2zU8YAKKaw+NJjxKIQTmiwwzeeqZhqM9WtuFmJ71+SFESbqMISQp9tf+HPZmydIDkBg
         DdGLrGSe6rH6xrNRGn+/cJwNX8lGuDBmFPOgsmlCxLWAiPMHWi3Y2LtVY0SF1nSoPo8O
         mFwA==
X-Gm-Message-State: APjAAAX9n4J/uq1K8lcQ8/N8bCuxgmAw8Gcg0ppRvG7y7wLKX3iUkRlp
	jJihT8wV8SPLmrSvgcve9jMtOg==
X-Google-Smtp-Source: APXvYqw1JCAIgiCqB+pKXAs2o/kKQN4tbl59wY+nts7LpDjypCtYx4/rlvkaywOcvdN+2GK2rbwv4w==
X-Received: by 2002:a05:6214:10ea:: with SMTP id q10mr15711217qvt.128.1565626151734;
        Mon, 12 Aug 2019 09:09:11 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id o50sm19991310qtj.17.2019.08.12.09.09.10
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Aug 2019 09:09:11 -0700 (PDT)
Message-ID: <1565626149.8572.1.camel@lca.pw>
Subject: Re: [PATCH] hugetlbfs: fix hugetlb page migration/fault race
 causing SIGBUS
From: Qian Cai <cai@lca.pw>
To: Sasha Levin <sashal@kernel.org>, Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton
 <akpm@linux-foundation.org>,  Mike Kravetz <mike.kravetz@oracle.com>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, ltp@lists.linux.it,  Li
 Wang <liwang@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
 Cyril Hrubis <chrubis@suse.cz>, xishi.qiuxishi@alibaba-inc.com
Date: Mon, 12 Aug 2019 12:09:09 -0400
In-Reply-To: <20190812153326.GB17747@sasha-vm>
References: <20190808074736.GJ11812@dhcp22.suse.cz>
	 <416ee59e-9ae8-f72d-1b26-4d3d31501330@oracle.com>
	 <20190808185313.GG18351@dhcp22.suse.cz>
	 <20190808163928.118f8da4f4289f7c51b8ffd4@linux-foundation.org>
	 <20190809064633.GK18351@dhcp22.suse.cz>
	 <20190809151718.d285cd1f6d0f1cf02cb93dc8@linux-foundation.org>
	 <20190811234614.GZ17747@sasha-vm> <20190812084524.GC5117@dhcp22.suse.cz>
	 <39b59001-55c1-a98b-75df-3a5dcec74504@suse.cz>
	 <20190812132226.GI5117@dhcp22.suse.cz> <20190812153326.GB17747@sasha-vm>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-08-12 at 11:33 -0400, Sasha Levin wrote:
> On Mon, Aug 12, 2019 at 03:22:26PM +0200, Michal Hocko wrote:
> > On Mon 12-08-19 15:14:12, Vlastimil Babka wrote:
> > > On 8/12/19 10:45 AM, Michal Hocko wrote:
> > > > On Sun 11-08-19 19:46:14, Sasha Levin wrote:
> > > > > On Fri, Aug 09, 2019 at 03:17:18PM -0700, Andrew Morton wrote:
> > > > > > On Fri, 9 Aug 2019 08:46:33 +0200 Michal Hocko <mhocko@kernel.org>
> > > > > > wrote:
> > > > > > 
> > > > > > It should work if we ask stable trees maintainers not to backport
> > > > > > such patches.
> > > > > > 
> > > > > > Sasha, please don't backport patches which are marked Fixes-no-
> > > > > > stable:
> > > > > > and which lack a cc:stable tag.
> > > > > 
> > > > > I'll add it to my filter, thank you!
> > > > 
> > > > I would really prefer to stick with Fixes: tag and stable only picking
> > > > up cc: stable patches. I really hate to see workarounds for sensible
> > > > workflows (marking the Fixes) just because we are trying to hide
> > > > something from stable maintainers. Seriously, if stable maintainers have
> > > > a different idea about what should be backported, it is their call. They
> > > > are the ones to deal with regressions and the backporting effort in
> > > > those cases of disagreement.
> > > 
> > > +1 on not replacing Fixes: tag with some other name, as there might be
> > > automation (not just at SUSE) relying on it.
> > > As a compromise, we can use something else to convey the "maintainers
> > > really don't recommend a stable backport", that Sasha can add to his
> > > filter.
> > > Perhaps counter-intuitively, but it could even look like this:
> > > Cc: stable@vger.kernel.org # not recommended at all by maintainer
> > 
> > I thought that absence of the Cc is the indication :P. Anyway, I really
> > do not understand why should we bother, really. I have tried to explain
> > that stable maintainers should follow Cc: stable because we bother to
> > consider that part and we are quite good at not forgetting (Thanks
> > Andrew for persistence). Sasha has told me that MM will be blacklisted
> > from automagic selection procedure.
> 
> I'll add mm/ to the ignore list for AUTOSEL patches.
> 
> > I really do not know much more we can do and I really have strong doubts
> > we should care at all. What is the worst that can happen? A potentially
> > dangerous commit gets to the stable tree and that blows up? That is
> > something that is something inherent when relying on AI and
> > aplies-it-must-be-ok workflow.
> 
> The issue I see here is that there's no way to validate the patches that
> go in mm/. I'd happily run whatever test suite you use to validate these
> patches, but it doesn't exist.
> 
> I can run xfstests for fs/, I can run blktests for block/, I can run
> kselftests for quite a few other subsystems in the kernel. What can I
> run for mm?

I have been running this for linux-next daily.

https://github.com/cailca/linux-mm

"test.sh" will give you some ideas. All the .config has almost all the MM
debugging options turned on, but it might need some modifications to run on QEMU
 etc.

"compile.sh" will have some additional MM debugging command-line options, and
some keywords to catch compilation warnings for MM.

> 
> I'd be happy to run whatever validation/regression suite for mm/ you
> would suggest.
> 
> I've heard the "every patch is a snowflake" story quite a few times, and
> I understand that most mm/ patches are complex, but we agree that
> manually testing every patch isn't scalable, right? Even for patches
> that mm/ tags for stable, are they actually tested on every stable tree?
> How is it different from the "aplies-it-must-be-ok workflow"?
> 
> --
> Thanks,
> Sasha
> 


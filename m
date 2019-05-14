Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7D15C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 23:07:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A77CC20873
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 23:07:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="T11Vup/c"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A77CC20873
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E22D6B0005; Tue, 14 May 2019 19:07:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2943B6B0006; Tue, 14 May 2019 19:07:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 183086B0007; Tue, 14 May 2019 19:07:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id EC6506B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 19:07:57 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id v22so458283ion.2
        for <linux-mm@kvack.org>; Tue, 14 May 2019 16:07:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fpPu6Srd12TWDsvx6xpShWyEQ5HvPxAwKNMasqNHAbk=;
        b=k4hZzvxx9v2kME9e4BZMIECDbw6Z2xgdkGolsr8mq70SsRWs+0VWqVQo7uN7fUCbPK
         J1KxiOppIfAxVg6ux2mXluoG9hTo8IM/Flx2m6ELqLlW88HODkDarnt9fMnvY0PaYCvU
         rRQPP8+HgOHA0X7BFZc8m4vdDTdXL7Ly/+DuKMBqdXxvAfcv8kApu/G1xX2fcQEExjme
         tuCEXUcaCBt3iJIwUand3M5X/4qWZgkZuSKq1oxOUUcvez2AiaNN5xZjSHP4ewkatP9l
         pC3COptNkiBMYh6o1VEdbed3nhGuOpzeVeK4ZM6YHVyX8oiokkjcZ/CdovQES/XkumYJ
         s8WQ==
X-Gm-Message-State: APjAAAVHx3boXU7EdIVON5eVgjronmlya1FMyfOCYJsQP4vMN7V+r6+Z
	pwpVe3CwnXExbhC6vj91IqIQB5TjW0YBC4N8No2HDioyHWfhYHGmptw1h2j0d18USjlAqZWtPjb
	zTc/AtFnC8ijYHqCrHY9Y0lOjRiUIrGW7bkGusavjlYqEO+Us15CHAm6nkuV7+OUxRA==
X-Received: by 2002:a24:4c4e:: with SMTP id a75mr6130559itb.42.1557875277715;
        Tue, 14 May 2019 16:07:57 -0700 (PDT)
X-Received: by 2002:a24:4c4e:: with SMTP id a75mr6130522itb.42.1557875277061;
        Tue, 14 May 2019 16:07:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557875277; cv=none;
        d=google.com; s=arc-20160816;
        b=dnGi3zhJSVjWt1lxQkdTOlsTe5emjPOWbefsbDus4RmRHXY1AS1kOWgUXr47M2ro51
         /4Un7rr8TvgHWNAj57bFnlXanL6iqdf0aH+ZcGcXVKrcUXH6x4LejrQzAY7QisP7Fm4N
         76zgWDvH96qKZlP66wdPpr90HH0+U35klJb+r2gdg6bMBP/KIX0kUBsTqz6muGo8qeZo
         SZuxowyVLEYj1Kz3CS7jrmL5oRRMAEkuEhSgW+LFH2PWO3SIy8sOjmQp1vySQsha7M70
         k7hV/YJ5SImCC+JmaCxhxRhs2h0zqAibNAYLNQMh+SSn7vTs1OAJsxMgzqpf+onaGCxD
         nkRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date:dkim-signature;
        bh=fpPu6Srd12TWDsvx6xpShWyEQ5HvPxAwKNMasqNHAbk=;
        b=gcudczmRD1ezB8bpAydgzkBPInO/lISN1Q6ycYXsGiW8HWBpCh2bMpmpKn0tnPama+
         GpyLHthrvUv/jCQ3/c0YCi1E8qbYvwIzDMzgyZq7xgZT7zkwxDiFWIlfSfPqybdN82/M
         7qg9PxUEE3L8VUbCJKSX9+CZHwhyZFG7as51J8mD59eFERY6vegcJZ5SdY/dzjHtPOQM
         6enzbCu1jrVkcYwZM+39QDRKiqP6zzUo0xZL0mStr/49l2ebBWjos+R/TqxqR0hGq0M1
         dtWmemNfX4SLqm4W8pppNwO8gfr8wbrJKX4GpktTpQg5SXIuKDLQ1CYu2FF/+olHCLi4
         gleg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="T11Vup/c";
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 186sor487536ita.36.2019.05.14.16.07.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 16:07:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="T11Vup/c";
       spf=pass (google.com: domain of yuzhao@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=yuzhao@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=fpPu6Srd12TWDsvx6xpShWyEQ5HvPxAwKNMasqNHAbk=;
        b=T11Vup/cYbfwY6YzAWV/mGwGD1gQDYyQC6G2BxXK4PPC718ZLMCye+aG74WCj5fos9
         09wYZgeFb/k3+WuqEj2zLbyGm+bkK2/fb3EhCCyuqqbpOLLYRADkdR71j6umz8fgOctZ
         oqF99nuKSPFnPGmRSiq5LQk19GqyNEeW44WFHIe5sd7P733SpJ5y5USvprGUccgWM81n
         nGOhxOhJ7X/f4vqn4W7KFFCnNxOOifuIbvXltdYt19gYBbkBHc5QoQjg7VswpWrjrFuw
         ecnaOdC9+M3e21yFG1yAo7HXSJsQE+PZ29OeX51tStLm2xS3s+V9hEk1Af9GkrlUK6et
         GgmQ==
X-Google-Smtp-Source: APXvYqxzoN7tuegV3gbfgvvbtn2Q1L1KZkn1XCuidG9PwFMOYDrpY9iAjhpTh23QbBLY6Tw5nU3lYw==
X-Received: by 2002:a24:8b07:: with SMTP id g7mr5386727ite.129.1557875276553;
        Tue, 14 May 2019 16:07:56 -0700 (PDT)
Received: from google.com ([2620:15c:183:0:9f3b:444a:4649:ca05])
        by smtp.gmail.com with ESMTPSA id m142sm199408itb.31.2019.05.14.16.07.55
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 14 May 2019 16:07:55 -0700 (PDT)
Date: Tue, 14 May 2019 17:07:51 -0600
From: Yu Zhao <yuzhao@google.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: don't expose page to fast gup before it's ready
Message-ID: <20190514230751.GA70050@google.com>
Reply-To: Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>
References: <20180108225632.16332-1-yuzhao@google.com>
 <20180109084622.GF1732@dhcp22.suse.cz>
 <20180109101050.GA83229@google.com>
 <20190514142527.356cb071155cd1077536f3da@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190514142527.356cb071155cd1077536f3da@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 14, 2019 at 02:25:27PM -0700, Andrew Morton wrote:
> On Tue, 9 Jan 2018 02:10:50 -0800 Yu Zhao <yuzhao@google.com> wrote:
> 
> > > Also what prevents reordering here? There do not seem to be any barriers
> > > to prevent __SetPageSwapBacked leak after set_pte_at with your patch.
> > 
> > I assumed mem_cgroup_commit_charge() acted as full barrier. Since you
> > explicitly asked the question, I realized my assumption doesn't hold
> > when memcg is disabled. So we do need something to prevent reordering
> > in my patch. And it brings up the question whether we want to add more
> > barrier to other places that call page_add_new_anon_rmap() and
> > set_pte_at().
> 
> Is a new version of this patch planned?

Sorry for the late reply. The last time I tried, I didn't come up
with a better fix because:
  1) as Michal pointed out, we need to make sure the fast gup sees
  all changes made before set_pte_at();
  2) pairing smp_wmb() in set_pte/pmd_at() with smp_rmb() in gup
  seems the best way to prevent any potential ordering related
  problems in the future;
  3) but this slows down the paths that don't require the smp_mwb()
  unnecessarily.

I didn't give it further thought because the problem doesn't seem
fatal at the time. Now the fast gup has changed and the problem is
serious:

	CPU 1				CPU 1
set_pte_at			get_user_pages_fast
page_add_new_anon_rmap		gup_pte_range
__SetPageSwapBacked (fetch)
				try_get_compound_head
				page_ref_add_unless
__SetPageSwapBacked (store)

Or the similar problem could happen to __do_huge_pmd_anonymous_page(),
for the reason of missing smp_wmb() between the non-atomic bit op
and set_pmd_at().

We could simply replace __SetPageSwapBacked() with its atomic
version. But 2) seems more preferable to me because it addresses
my original problem:

> > I didn't observe the race directly. But I did get few crashes when
> > trying to access mem_cgroup of pages returned by get_user_pages_fast().
> > Those page were charged and they showed valid mem_cgroup in kdumps.
> > So this led me to think the problem came from premature set_pte_at().

Thoughts? Thanks.


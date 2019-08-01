Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28EE9C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 06:51:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B6E80216C8
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 06:51:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="r8pAoGTe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6E80216C8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 62D648E0005; Thu,  1 Aug 2019 02:51:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5DE8D8E0001; Thu,  1 Aug 2019 02:51:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A6E68E0005; Thu,  1 Aug 2019 02:51:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0F21C8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 02:51:16 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 191so45017487pfy.20
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 23:51:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=Z+wSy2NIw56Ih4OG3All4gi2gj6xpW5h+aVJhlgDXzA=;
        b=UTWFL1iTipQNFrmq3sgMInh+W2+RqPhSptvjtsikEhW6eesxl5l6R3A2RxtY1kOTtx
         8nNKZJzARSg8E71B+ZRkmOKfgXJ6gwdzOswRqtIJLJRSbGzmKfOJeeFmWCmVJa6BnNO0
         jHhDXP0sPMyMb9xfdmbcuiqX5By1CKkgDQzoqexSBkV1e2TP574k3NkwBJ9sYkNReO0Z
         2DHxTy7RTc6id/mxMGPz+eb5eTVixTE7XbLRV3+T8Qyz7HxzMszxUqJ3VJWGpNnWYyu5
         0p7RqpRjmnUJRuACJL8L+VkOrhsNSPiU+e5TtrrCnmV95a5junDt9+Xgly8R8X0wc1+v
         DVOw==
X-Gm-Message-State: APjAAAWjGCMgPzcvXkxVjuMJFEhp7V6u6Vl5T+RZsoTDD0I5m0GH5xSk
	oFC4zUiL0ezXMRlxeRZzOoQ8JbvHw/Cfl1RBZYOFWOGEITa+Dv+WtYKXQT3dydG+0K5kVToQne7
	B3kfEUhmJfA+GSp1R9RbnoTT5C2uIr+/zF8oSeHiO68ZUcn8W8VAIhS4xWDbX7tk=
X-Received: by 2002:a63:6205:: with SMTP id w5mr857858pgb.199.1564642275481;
        Wed, 31 Jul 2019 23:51:15 -0700 (PDT)
X-Received: by 2002:a63:6205:: with SMTP id w5mr857818pgb.199.1564642274618;
        Wed, 31 Jul 2019 23:51:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564642274; cv=none;
        d=google.com; s=arc-20160816;
        b=bowKB+i05xF5ZDk/EsBWfPP9x4kHfm7A7G9D7cHcZ7fflY9VOJjf9FPUJAfRBp0uoD
         66qaxLuSvPP4mt8+BLxN6gvIMY4pMZd1kpeV2mu4xHUIcBfnINpAy8DhOVchEu5f7/MV
         SqUVy/9IlZ64gumtV2GOENNrnGWoe8lvb/VUPK8sofk0KxmILlK8voU79u3cECd43FOS
         3CzHilIzOvTJwkhB4Cnsq8vavpcal0HJzXVo39VaigZ+hkHFOLl9j7iiLaFPlFzpFcey
         46pChmqjwpZTU3fQfrj5jKhzMOvmQ18F5MvklK3WO69z8Jm/bwpfoE1tSSSG531uswYT
         /HQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:sender:dkim-signature;
        bh=Z+wSy2NIw56Ih4OG3All4gi2gj6xpW5h+aVJhlgDXzA=;
        b=V1nN5HhzNm7rO7Gqh8uHbs5pNt8qX1wJsOMOjTDdJLUEMer5EamvL9BTZyYx6AtX5v
         iS6gdZzubfNl/X3+4qQXXyWPCKf+LXNfHpSBLm7q7ohJdHw+wtToiPjC2mZj7Vqmefsx
         YhhNDQ54rz4Rs24wVjuu9r5YhoqdhjjhT2UyYBA+bPy3QtGxp3NgUqvY8ZIbLZKiwIiL
         hvtzSGsQqUfy4O6BRAVrBh0D3EeTtaWC8wnTM3ZolMsX3LmMcgRhID+GSfgAOMNAqkqT
         RNiiiPLZjqSiPTsrfH8tn5LO4y81c41LL7PQGYMGj0hrVIcJKuXAr0opiDjee5VuQvDY
         dWAw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=r8pAoGTe;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g95sor84448283plb.67.2019.07.31.23.51.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 23:51:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=r8pAoGTe;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=Z+wSy2NIw56Ih4OG3All4gi2gj6xpW5h+aVJhlgDXzA=;
        b=r8pAoGTe3awW6RqIb2JqB64N65oxWNjwZpK9U+UXIWwcqb+ujBDnbvMeMHHEzzir9v
         d46oiI1XmFzexTj1Xu896UiMhyfqyE/kOe6/3stzVI7dx5oCND6SQ9PHDMkDB0pjvJav
         W6FZZ89AqXASzs4uf4LnPBsZgpf65bHmKu+IHifu2EmNIRiRfTxKaU2SvCmAPbNeK+4g
         Ha8hpTayyvBCWIgMwCCRN9Rg6EF6QjpCf89kkrQDr/hc8BzJxCZV1W1V9xZ3fDS78O/Z
         EuNKEJUyvd76Zd9TySZxqHM8Tpk6OXyL9ztVUtRvTzf7kPDte1n4bWVX73xC/4c1hLhb
         rmIQ==
X-Google-Smtp-Source: APXvYqy7MQ5OSx4BlyyKB0FvW0mnEEtl3nm0LuK11aKIVzBcR5piytGZo7Q6qT+E/6AfdFy4BVnfUA==
X-Received: by 2002:a17:902:b713:: with SMTP id d19mr125415539pls.267.1564642274050;
        Wed, 31 Jul 2019 23:51:14 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id 33sm83795415pgy.22.2019.07.31.23.51.11
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 31 Jul 2019 23:51:12 -0700 (PDT)
Date: Thu, 1 Aug 2019 15:51:08 +0900
From: Minchan Kim <minchan@kernel.org>
To: Qian Cai <cai@lca.pw>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: "mm: account nr_isolated_xxx in [isolate|putback]_lru_page"
 breaks OOM with swap
Message-ID: <20190801065108.GA179251@google.com>
References: <1564503928.11067.32.camel@lca.pw>
 <20190731053444.GA155569@google.com>
 <1564589346.11067.38.camel@lca.pw>
 <1564597080.11067.40.camel@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1564597080.11067.40.camel@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 02:18:00PM -0400, Qian Cai wrote:
> On Wed, 2019-07-31 at 12:09 -0400, Qian Cai wrote:
> > On Wed, 2019-07-31 at 14:34 +0900, Minchan Kim wrote:
> > > On Tue, Jul 30, 2019 at 12:25:28PM -0400, Qian Cai wrote:
> > > > OOM workloads with swapping is unable to recover with linux-next since
> > > > next-
> > > > 20190729 due to the commit "mm: account nr_isolated_xxx in
> > > > [isolate|putback]_lru_page" breaks OOM with swap" [1]
> > > > 
> > > > [1] https://lore.kernel.org/linux-mm/20190726023435.214162-4-minchan@kerne
> > > > l.
> > > > org/
> > > > T/#mdcd03bcb4746f2f23e6f508c205943726aee8355
> > > > 
> > > > For example, LTP oom01 test case is stuck for hours, while it finishes in
> > > > a
> > > > few
> > > > minutes here after reverted the above commit. Sometimes, it prints those
> > > > message
> > > > while hanging.
> > > > 
> > > > [  509.983393][  T711] INFO: task oom01:5331 blocked for more than 122
> > > > seconds.
> > > > [  509.983431][  T711]       Not tainted 5.3.0-rc2-next-20190730 #7
> > > > [  509.983447][  T711] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
> > > > disables this message.
> > > > [  509.983477][  T711] oom01           D24656  5331   5157 0x00040000
> > > > [  509.983513][  T711] Call Trace:
> > > > [  509.983538][  T711] [c00020037d00f880] [0000000000000008] 0x8
> > > > (unreliable)
> > > > [  509.983583][  T711] [c00020037d00fa60] [c000000000023724]
> > > > __switch_to+0x3a4/0x520
> > > > [  509.983615][  T711] [c00020037d00fad0] [c0000000008d17bc]
> > > > __schedule+0x2fc/0x950
> > > > [  509.983647][  T711] [c00020037d00fba0] [c0000000008d1e68]
> > > > schedule+0x58/0x150
> > > > [  509.983684][  T711] [c00020037d00fbd0] [c0000000008d7614]
> > > > rwsem_down_read_slowpath+0x4b4/0x630
> > > > [  509.983727][  T711] [c00020037d00fc90] [c0000000008d7dfc]
> > > > down_read+0x12c/0x240
> > > > [  509.983758][  T711] [c00020037d00fd20] [c00000000005fb28]
> > > > __do_page_fault+0x6f8/0xee0
> > > > [  509.983801][  T711] [c00020037d00fe20] [c00000000000a364]
> > > > handle_page_fault+0x18/0x38
> > > 
> > > Thanks for the testing! No surprise the patch make some bugs because
> > > it's rather tricky.
> > > 
> > > Could you test this patch?
> > 
> > It does help the situation a bit, but the recover speed is still way slower
> > than
> > just reverting the commit "mm: account nr_isolated_xxx in
> > [isolate|putback]_lru_page". For example, on this powerpc system, it used to
> > take 4-min to finish oom01 while now still take 13-min.
> > 
> > The oom02 (testing NUMA mempolicy) takes even longer and I gave up after 26-
> > min
> > with several hang tasks below.
> 
> Also, oom02 is stuck on an x86 machine.

Yeb, above my patch had a bug to test page type after page was freed.
However, after the review, I found other bugs but I don't think it's
related to your problem, either. Okay, then, let's revert the patch.

Andrew, could you revert the below patch?
"mm: account nr_isolated_xxx in [isolate|putback]_lru_page"

It's just clean up patch and isn't related to new madvise hint system call now.
Thus, it shouldn't be blocker.

Anyway, I want to fix the problem when I have available time.
Qian, What's the your config and system configuration on x86?
Is it possible to reproduce in qemu?
It would be really helpful if you tell me reproduce step on x86.

Thanks.


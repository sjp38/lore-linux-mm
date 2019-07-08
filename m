Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40BA3C606C1
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 16:43:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0A93216C4
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 16:43:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0A93216C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 87D2E8E001F; Mon,  8 Jul 2019 12:43:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 82D338E0002; Mon,  8 Jul 2019 12:43:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F6AC8E001F; Mon,  8 Jul 2019 12:43:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 227EA8E0002
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 12:43:18 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id w25so7398989edu.11
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 09:43:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fMc3+ee1jq/+/qYJcXEm4rugSNJJkPr1r0mIKLNgeco=;
        b=eK5anr6QriilQCSDHZPpIZYgHHCZjj1et0IJMbug15BchKEm+2hVtYzTUmWuMggsyg
         IzCTqUKIQdLmfjK04CBBk0XTvdYY6cj7QRh+0mEl3yHxdMOv2ySoHUuIFu5MFs8swTwf
         3y+Ul92CyF0l+FflduD0kS8lwczB5O33ARhQ2QhSCJX9sD62gRJi7wYYXz+sdYR3wHl0
         Ua8UKczjAO2fedrAbXhggpMRc/HQIq87x+yN9rC0rXAKUel8lbmuwztw6kmAXgMS3GkW
         +WFwHNbmGIFASZyNajRTx8WTp+j0jjJsse5sBrZyaddxpyYat9JMxkYzskioKlwWTrv5
         vKjQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAWfQJtTmsftpVg5murnCrh+mB+sxd5QHJvz/1lgD/tLTsBr4HAm
	75cOX7fn96RT3KLiA8uEOkVtcyQ5ufdB5CJDDaPX6WNqhxZ2/OAuoBqRLHz4y0rfRQHNNf3Diyl
	sfNfmRZUCsmLR6h8zjrAUp1/V2o/DuzgdqDzfX3lkG5e+8adZ5OHSvaZKdnw8T+ZNYQ==
X-Received: by 2002:a50:b60a:: with SMTP id b10mr21225257ede.113.1562604197665;
        Mon, 08 Jul 2019 09:43:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzwOWSti1ExjUKXkG1E8VC5zm9tpslbBM5b1RPevSDbV57ajsIGZKcqpUiZtudzDWgctWrV
X-Received: by 2002:a50:b60a:: with SMTP id b10mr21225184ede.113.1562604196575;
        Mon, 08 Jul 2019 09:43:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562604196; cv=none;
        d=google.com; s=arc-20160816;
        b=dzAhFFi83Np1PZ7FjiVX+alNIVBurQ4P3CXOTujUbKAaSRhyX/uRRkjtPgh1c3zteq
         dAgGZKSOeySE7sPc73i9Xnb43dt/gjqNU4Z5fU3mvgRVggWcPUqv3JTL1u1R0eBb509S
         JzoHGbw4QZedOzMUVG/holYhVGMmEPpLqiJe3rou2Kxo2lu/mn6J7tNE6iMvrkllYPxE
         7oMV8O+QbuQsuDrpVl7B41p/KxiX9d9TwMCt8tkVmyFq4Ew/W984d2iQrEs0kuT7C6NK
         lytXyoF0pMAqOJKgC53XB/Fqb76/ccu1ncQfzYbH5pwPsE6euN84nrk8RgsxuC2Zvvye
         NaZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fMc3+ee1jq/+/qYJcXEm4rugSNJJkPr1r0mIKLNgeco=;
        b=b2ANKNnoT/j33QBUFtPAfgY1GvW0xOcPDpNLjvfv4VO94k5hlLz06NnBjE/MRqXfQE
         4IesldFQmCod1r03z/DEUr3GcnS3rA3QuRwIvabwzGLeW4dQYPowwRs2qdsZkOwpkPYB
         Ptd7qSfL0gfF+iQlfeTGvfHVxjgNCuYKzYe9zpKKdaW2HgF2Z1+8y/EAkRSjLG3fGLaq
         pAef4UCJJ4pONTMhPfC26KU6U1xTxPucjBa1Bp5RBUCWM6vcjvIQiUByZJiAXjwqgrck
         1cfogiMubtl6pHybAFaYxr/YPC7Xxf/zeARA8K2MSzZs3++h6Y96aWkN+D6HuqsEfhnh
         ryIA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m2si10611338ejo.156.2019.07.08.09.43.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jul 2019 09:43:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1822AAF39;
	Mon,  8 Jul 2019 16:43:16 +0000 (UTC)
Date: Mon, 8 Jul 2019 18:43:14 +0200
From: Michal Hocko <mhocko@suse.com>
To: zhong jiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, anshuman.khandual@arm.com, mst@redhat.com,
	linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH] mm: redefine the MAP_SHARED_VALIDATE to other value
Message-ID: <20190708164314.GE20617@dhcp22.suse.cz>
References: <1562573141-11258-1-git-send-email-zhongjiang@huawei.com>
 <20190708092045.GA20617@dhcp22.suse.cz>
 <5D234AB5.2070508@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5D234AB5.2070508@huawei.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 08-07-19 21:52:53, zhong jiang wrote:
> On 2019/7/8 17:20, Michal Hocko wrote:
> > [Cc Dan]
> >
> > On Mon 08-07-19 16:05:41, zhong jiang wrote:
> >> As the mman manual says, mmap should return fails when we assign
> >> the flags to MAP_SHARED | MAP_PRIVATE.
> >>
> >> But In fact, We run the code successfully and unexpected.
> > What is the code that you are running and what is the code version.
> Just an following code, For example,
> addr = mmap(ADDR, PAGE_SIZE, PROT_WRITE|PROT_EXEC, MAP_SHARED|MAP_PRIVATE, fildes, OFFSET);

Is this a real code that relies on the failure or merely a simple test
to reflect the semantic you expect mmap to have?

> We test it and works well in linux 4.19.   As the mmap manual says,  it should fails.
> >> It is because MAP_SHARED_VALIDATE is introduced and equal to
> >> MAP_SHARED | MAP_PRIVATE.
> > This was a deliberate decision IIRC. Have a look at 1c9725974074 ("mm:
> > introduce MAP_SHARED_VALIDATE, a mechanism to safely define new mmap
> > flags").
> I  has seen the patch,  It introduce the issue.  but it only define the MAP_SHARED_VALIDATE incorrectly.
> Maybe the author miss the condition that MAP_SHARED_VALIDATE is equal to MAP_PRIVATE | MAP_SHARE.

No you are missing the point as Willy pointed out in a different email.
This is intentional. No real application could have used the combination
of two flags because it doesn't make any sense. And therefore the
combination has been chosen to chnage the mmap semantic and check for
valid mapping flags. LWN has a nice coverage[1].


[1] https://lwn.net/Articles/758594/
-- 
Michal Hocko
SUSE Labs


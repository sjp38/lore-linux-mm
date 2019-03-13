Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BCECC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 16:33:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA11E2146E
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 16:33:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA11E2146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 62C248E0003; Wed, 13 Mar 2019 12:33:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5DA928E0001; Wed, 13 Mar 2019 12:33:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F1298E0003; Wed, 13 Mar 2019 12:33:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0F4DB8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:33:10 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id w16so2723191pfn.3
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 09:33:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=K3s/wb0K11ci6QSQvX1zI7+LS/aGT46CY+E57M7Cxp8=;
        b=PPY7Skqthf10L2ONKxjU37LUYiaOLNpGRR3DVo5f5O9N7MjcLhYkD4q8AbqYncLc33
         vLxehH4+v5J7mBM/KFXslIrzGYOwvhIN1WXaPdNlAQkcXtAbtJ/Va954kxsO7ueWXUJT
         rJTBc65SV3aYdyRLi9KSAJAeQ8phokA0e4fjPH0ucnhcd7or67Kpyz0gn0955qeuC/5r
         uRa6LvULefPABD6emDWcCHCxjGoGgzSzKG06fdlcuYNCKJUhFyAZqVSR/ZfGa1SsoJvO
         iDdSvBFnJRf/K7hdZHm887Of0YvOmKW+Nr14VBWVlrwx0lJjCewgmCcGU2gt/tjq4mtS
         BPwA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAUaIXwZbg7POmO1PxGo8EknpsLhqVCcD3mdMyrXw7KK4Qo4iiOP
	++iM4BLnB+f6VcwxTQrAp002FQ5xKSJMurPf4fgB7fPSNgeO2YzcHczX5ROHd5FgMbMO6O/FzcH
	cj8xxVwGOPOWkZwWo2WxS7wQ9mYDj3/kqaopoqciqRoBYqind172tN4uRnHgpyLTHRg==
X-Received: by 2002:a62:2ad1:: with SMTP id q200mr44102805pfq.34.1552494789686;
        Wed, 13 Mar 2019 09:33:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzwGrPVq5xviqDdEaGD8oFTSSy3EMbP+fqhirYiKnwvBiDSmnVLF7i6w82RxxfXQPupU9s7
X-Received: by 2002:a62:2ad1:: with SMTP id q200mr44102755pfq.34.1552494788676;
        Wed, 13 Mar 2019 09:33:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552494788; cv=none;
        d=google.com; s=arc-20160816;
        b=kEvNwusybTZibf5Rlzuj2Xmm8VxSuIIFIAu5+Vj/n02KgA0p40R/RbwlVu536k7CHo
         tqYLogDOeOOGoheKNiW7auk6CmURYchPy9YEz3klJexeI65IQ1KppkM48wqyQ7SbDcMB
         MnUx9gLXkbzfGIYkJ2rtZ7RxdMF9X1/AVVbm3oXNPpGvUKzbvssh1GCPB5KqF2An6hxg
         xEwcea1XiIWRCA1vMlijWE9PzbUBVZ57/QEXx4bvlGixf9bNtIZtponODy0JWMRExcIf
         j3KPU6cmrqd9HiaRRMA9UPzpZ8Epp7zJDRFi/xdCfPpgLbMI5q8eMzCIb9glXT2hQcx6
         ljXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=K3s/wb0K11ci6QSQvX1zI7+LS/aGT46CY+E57M7Cxp8=;
        b=tUuBF47vEoWF11so40X3wEuq04Xyel6wYbt4rRylQ55DYgGrckYNPLqLe9uoCZK/rv
         lZEIf6KwXikaP9tHIjcPyv7wD6zS0hLXJPJMZNx+KKFedZpUgDCnHEXkXjUhP1lmiBOJ
         cY5wLindx1uWlYM5oNY3VIHltSYmTS4TLqy4oPBJ1FrtjpGhzrElqywBBmvuAllxvCUw
         cpiRQJwRtmU5NnRQ9s+VljbUcp7R5AEVqDSiqwNcrbkwEcSGbH28PrYsAw361R29ej46
         bUZHGHr+hskcwt0oPDQikIHT3xsRxN89NqX5Kkv3uYKYILyUVejXZ/moEVxapdqvQAk3
         OtrA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b1si11434684pla.382.2019.03.13.09.33.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 09:33:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 7739ECB7;
	Wed, 13 Mar 2019 16:33:07 +0000 (UTC)
Date: Wed, 13 Mar 2019 09:33:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org,
 sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-nvdimm@lists.01.org, davem@davemloft.net,
 pavel.tatashin@microsoft.com, mingo@kernel.org,
 kirill.shutemov@linux.intel.com, dan.j.williams@intel.com,
 dave.jiang@intel.com, rppt@linux.vnet.ibm.com, willy@infradead.org,
 vbabka@suse.cz, khalid.aziz@oracle.com, ldufour@linux.vnet.ibm.com,
 mgorman@techsingularity.net, yi.z.zhang@linux.intel.com
Subject: Re: [mm PATCH v6 6/7] mm: Add reserved flag setting to
 set_page_links
Message-Id: <20190313093306.c4b49c6d062f506a967f843d@linux-foundation.org>
In-Reply-To: <4c72a04bb87e341ea7c747d509f42136a99a0716.camel@linux.intel.com>
References: <154361452447.7497.1348692079883153517.stgit@ahduyck-desk1.amr.corp.intel.com>
	<154361479877.7497.2824031260670152276.stgit@ahduyck-desk1.amr.corp.intel.com>
	<20181205172225.GT1286@dhcp22.suse.cz>
	<19c9f0fe83a857d5858c386a08ca2ddeba7cf27b.camel@linux.intel.com>
	<20181205204247.GY1286@dhcp22.suse.cz>
	<20190312150727.cb15cbc323a742e520b9a881@linux-foundation.org>
	<4c72a04bb87e341ea7c747d509f42136a99a0716.camel@linux.intel.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Mar 2019 15:50:36 -0700 Alexander Duyck <alexander.h.duyck@linux.intel.com> wrote:

> On Tue, 2019-03-12 at 15:07 -0700, Andrew Morton wrote:
> > On Wed, 5 Dec 2018 21:42:47 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > > > I got your explanation. However Andrew had already applied the patches
> > > > and I had some outstanding issues in them that needed to be addressed.
> > > > So I thought it best to send out this set of patches with those fixes
> > > > before the code in mm became too stale. I am still working on what to
> > > > do about the Reserved bit, and plan to submit it as a follow-up set.
> > > > From my experience Andrew can drop patches between different versions of
> > > the patchset. Things can change a lot while they are in mmotm and under
> > > the discussion.
> > 
> > It's been a while and everyone has forgotten everything, so I'll drop
> > this version of the patchset.
> > 
> 
> As far as getting to the reserved bit I probably won't have the time in
> the near future. If I were to resubmit the first 4 patches as a
> standalone patch set would that be acceptable, or would they be held up
> as well until the reserved bit issues is addressed?
> 

Yes, I think that merging the first four will be OK.  As long as they
don't add some bug which [5/5] corrects, which happens sometimes!

Please redo, retest and resend sometime?


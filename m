Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9FB6C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 19:24:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 884BB218FD
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 19:24:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 884BB218FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 25A4A6B0003; Thu, 21 Mar 2019 15:24:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 20B446B0006; Thu, 21 Mar 2019 15:24:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 121BA6B0007; Thu, 21 Mar 2019 15:24:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id AF9476B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 15:24:06 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id z98so7575ede.3
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 12:24:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8weNsJTuKZGAdIoMI50Jpf+7Hpo+FzCe3w4h6hu+9b8=;
        b=OPqL6aLs1pqtZZlAMhvpw8yZHRouj1tzcjCQ5224K3eskUFUi9YlYsEasTN2zdP/sG
         JexxugNtrbxOA9R6sgOp4TXjzgNoIUSFUGqFGIUQ7omK3xul89Wpri4kMhSsEaRddAMn
         7p6j4knClsKsrK/c0uSD/M/IFY2Gc1ea1t/BS9H7xMoDbnouT+yyeUvkVMyyIT/2556w
         Jy57Q1TUcLLVpU28qCYdKpuu3VuEaLgIGoYgOiq02R4GGtifsWRtR9FXOj9v3l+DVHe6
         IPxU1QShj0kOQalO//ue/EBeLoHiXWLwxuti0Phci+eoORyHv5O1Xk4mHcNWE2OhS3ga
         jwMA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAU4PEpoYhAeDR1p8rztStZIFiFOUKrxmRDP/rsLwtLiNnSkeOov
	dP3e/A1jDgfWlalZwkKGgqm9i9G0EMbgdBQ59h/SnVbyMRg/Jqb9JANTMw5f5eNnJTaDESUdUwS
	AcUyWQT+Dky+Mf0ftGsxl5LNlebKL7p1UpV+PHWwh6Xxl9VwDrE6PnDQbwFQVqCto/w==
X-Received: by 2002:a50:a547:: with SMTP id z7mr3501747edb.58.1553196246268;
        Thu, 21 Mar 2019 12:24:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwDmrW7p9054oXDwf5gWpmu4jYM8APhcAinJJPROXWWX2fn4WlK7nELZcO732W0iZvhW5Qb
X-Received: by 2002:a50:a547:: with SMTP id z7mr3501699edb.58.1553196245155;
        Thu, 21 Mar 2019 12:24:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553196245; cv=none;
        d=google.com; s=arc-20160816;
        b=QF1eIfi8tVMhV653A/Z8MO0/TRw7W4lX0OIWPlMXllj9pzS3sRcpVPjlE+M+m9We/8
         TS7kOPmVQIp0+QmlTPRK4UE7ttZ5MMRbNmnj4wOjiD7px1U9t57CJ89ljOLs6deYfkJr
         8MC2eaTyZNNOUbRIT5CP40vbflI53MizjF6TQbr/cb4QIaUjta6cdwQYzqXTZGHzsoO/
         tzbw28PoZP0vbaYi8JUiXRqjjbVsQ3V4DMkP/q6wND47OOgH0zQcxQ1DNDfL/TDC5TVI
         2t1+RQjbwQNnwZIOQoXmTPFJkVb4tP05D+D2vamyegADQBrIbwFRJfdjGnCkYEXlX58w
         T+xQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8weNsJTuKZGAdIoMI50Jpf+7Hpo+FzCe3w4h6hu+9b8=;
        b=PP11WYjxDBbzLwnVp7SorIsqnuUTpGS9hJupPr6tBAhCDabc92jDPOrZ2XPYdS9Lag
         e3l69EoXzr4ysCJxnw1Ooz3xifoC62bn7aK54KLhDtFXdr9LAxdBCKT5+GnPMcVeLpd/
         qrf94j+mWYZhCFFV3ns3eHaZd98H7nFTv36+ZzXt2TC6U/e462RMg368gGKpw/PJ2lVn
         YkMmyMoC+RRP2+4GODdkzp8qCQGxgCBO7LyQZ7Y4U6j+M5ggTpa5ebt3s7Yad16Yu44H
         mBjXw1+Oo3eAmqPQo9wnt+/jA3C+XyLz+OOcfp+tLJBicW6SZVC6XMo8P3MdFps2jmRd
         umYw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id v21si2374982edm.85.2019.03.21.12.24.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 12:24:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) client-ip=46.22.139.17;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id B4BDF1C2B69
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 19:24:04 +0000 (GMT)
Received: (qmail 27968 invoked from network); 21 Mar 2019 19:24:04 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 21 Mar 2019 19:24:04 -0000
Date: Thu, 21 Mar 2019 19:24:03 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Michal Hocko <mhocko@kernel.org>, vbabka@suse.cz,
	akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH] mm: mempolicy: remove MPOL_MF_LAZY
Message-ID: <20190321192403.GF3189@techsingularity.net>
References: <1553041659-46787-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190321145745.GS8696@dhcp22.suse.cz>
 <75059b39-dbc4-3649-3e6b-7bdf282e3f53@linux.alibaba.com>
 <20190321165112.GU8696@dhcp22.suse.cz>
 <60ef6b4a-4f24-567f-af2f-50d97a2672d6@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <60ef6b4a-4f24-567f-af2f-50d97a2672d6@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 21, 2019 at 10:25:08AM -0700, Yang Shi wrote:
> 
> 
> On 3/21/19 9:51 AM, Michal Hocko wrote:
> > On Thu 21-03-19 09:21:39, Yang Shi wrote:
> > > 
> > > On 3/21/19 7:57 AM, Michal Hocko wrote:
> > > > On Wed 20-03-19 08:27:39, Yang Shi wrote:
> > > > > MPOL_MF_LAZY was added by commit b24f53a0bea3 ("mm: mempolicy: Add
> > > > > MPOL_MF_LAZY"), then it was disabled by commit a720094ded8c ("mm:
> > > > > mempolicy: Hide MPOL_NOOP and MPOL_MF_LAZY from userspace for now")
> > > > > right away in 2012.  So, it is never ever exported to userspace.
> > > > > 
> > > > > And, it looks nobody is interested in revisiting it since it was
> > > > > disabled 7 years ago.  So, it sounds pointless to still keep it around.
> > > > The above changelog owes us a lot of explanation about why this is
> > > > safe and backward compatible. I am also not sure you can change
> > > > MPOL_MF_INTERNAL because somebody still might use the flag from
> > > > userspace and we want to guarantee it will have the exact same semantic.
> > > Since MPOL_MF_LAZY is never exported to userspace (Mel helped to confirm
> > > this in the other thread), so I'm supposed it should be safe and backward
> > > compatible to userspace.
> > You didn't get my point. The flag is exported to the userspace and
> > nothing in the syscall entry path checks and masks it. So we really have
> > to preserve the semantic of the flag bit for ever.
> 
> Thanks, I see you point. Yes, it is exported to userspace in some sense
> since it is in uapi header. But, it is never documented and MPOL_MF_VALID
> excludes it. mbind() does check and mask it. It would return -EINVAL if
> MPOL_MF_LAZY or any other undefined/invalid flag is set. See the below code
> snippet from do_mbind():
> 

That does not explain the motivation behind removing it or what we gain.
Yes, it's undocumented and it's unlikely that anyone will. Any potential
semantics are almost meaningless with mbind but there are two
possibilities. One, mbind is relaxed to allow migration within allowed
nodes and two, interleave could initially interleave but allow migration
to local node to get a mix of average performance at init and local
performance over time. No one tried taking that option so far but it
appears harmless to leave it alone too.

-- 
Mel Gorman
SUSE Labs


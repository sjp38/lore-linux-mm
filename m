Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74F41C742B1
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 09:49:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4381D2064B
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 09:49:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4381D2064B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D70898E0132; Fri, 12 Jul 2019 05:49:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D1F9E8E00DB; Fri, 12 Jul 2019 05:49:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C36288E0132; Fri, 12 Jul 2019 05:49:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 734BF8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 05:49:23 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id r21so7334025edc.6
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 02:49:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=GAu6HXeOJfi7A0BJ2gwACMGzjPLBlyanX0kptwOr6Rs=;
        b=FQWsWHQsi9nFhbONa9Hdz30c9bPoloIBbjrR0zSAUXLmywM4eYe+5zhX22D4B0VnSI
         Ms3nXpvsFHUGHm78HjfYP95hRvZjYVVbwVahoCg79fuO6Xvz7N7i3/uxX/+++ff96+kO
         +4Mie3BsIyywrcmVQRpAEZ1Kx/3ukIGQuEGuaD6viK8WLs2kNsJMx02DOmxK3myLSHbl
         JuLxb9FYe5wbn4Z6r8DcITv8XCcNBz1K97VQWnF1xmhh8LNiQcUSw79jcJuv8WeG+ix4
         kIvduRPQlGgsKo1BNhw8PpFmw0iYS3lvqs4na1HjJokFSLI+OqqXdj9BmR1jsOxjTWNs
         YEqg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Gm-Message-State: APjAAAUyZUmEBKuWs0LNPPOz+aHqTbAYOMEhHwGhHfJ1II6ZDf6NUCUn
	ZxhUcx77rZdDX1K0RW4WJVcf8EUz7avnnnZVEGy2qj23VGX7rIijr9MDqETL1mLFDRbh4/ZURRP
	qOfy9FptbuU1X1ec6xvj9To1mtZn4GcHO1VFTR3N1o6H5yAf0r6nubSopOlBGJgCsqg==
X-Received: by 2002:a50:90c5:: with SMTP id d5mr8481348eda.28.1562924963043;
        Fri, 12 Jul 2019 02:49:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwo4/S4I61q+YwT3qzaDJygTcXDfUbtlecs+lx6h2hoKooRcczLnWMf3gGjW7NxZomktKN6
X-Received: by 2002:a50:90c5:: with SMTP id d5mr8481296eda.28.1562924962286;
        Fri, 12 Jul 2019 02:49:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562924962; cv=none;
        d=google.com; s=arc-20160816;
        b=sG5nkBYfEmlL0Y0oiVlwt9uaVW+8HFvc0zFAsPhzm4fbL3ib/E1vSTAP0qZ9jr5JVV
         mbz5tirXLC4i1cqB6Q/3d329v4Rjk8XZ19hmmZGec9AUFQpNKJsmvDEhduWCoyhN2X8D
         p+98CME+qmVD43JsI2peuNBEavIe5/wIUjaAngyV/L6dXnunyTsK0gahmlxJOC75ttvG
         XkBntvhoVorEaOx0c3mvtr847BfaL2zfaykw8BQM8MryzRx/FIGXv3s8XMEmrpP+/+L4
         4NrAn9mB/Z9yoAsYsofrgjEbaBj/qsXD6NBSyGKJi1/68vKOXxWv5BBcO1FmOMBgGyVK
         iuKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=GAu6HXeOJfi7A0BJ2gwACMGzjPLBlyanX0kptwOr6Rs=;
        b=SaVj0PjpCCq40a9+3SJ4QtGKKg7IRZU0vMuquwo7IEVRcaYbKbqXOzYrLeC1N5Wk6I
         8CoLgpfIuXwXxWCWqvyLFF0hWUjgac3f0mWOScLGc1guNrtvzVA2w9qhub9P82tp7omn
         PaUAP3hY99UL6+w5FUODU0S+y9aMhCBmg/PxIPNrG05tlwhuEzbTxchTIrfDQakceFR8
         V/SAQNU5+VyZCN1z/dvzMEtuUxqe3KUXRRUm2CK80bg1WCIxFbw6pX/AeX0L9OGV2Gd/
         00NNTra8JgL89PSWXa8cQblUmyqB8HK/YwozNW5fEq02ihCP8hxwQrBRu+2d6XDd5XW9
         Hl/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j24si4447138ejt.212.2019.07.12.02.49.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 02:49:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 90E6EAF6B;
	Fri, 12 Jul 2019 09:49:21 +0000 (UTC)
Date: Fri, 12 Jul 2019 10:49:19 +0100
From: Mel Gorman <mgorman@suse.de>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, Hillf Danton <hdanton@sina.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [Question] Should direct reclaim time be bounded?
Message-ID: <20190712094919.GI13484@suse.de>
References: <d38a095e-dc39-7e82-bb76-2c9247929f07@oracle.com>
 <80036eed-993d-1d24-7ab6-e495f01b1caa@oracle.com>
 <885afb7b-f5be-590a-00c8-a24d2bc65f37@oracle.com>
 <20190710194403.GR29695@dhcp22.suse.cz>
 <9d6c8b74-3cf6-4b9e-d3cb-a7ef49f838c7@oracle.com>
 <20190711071245.GB29483@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190711071245.GB29483@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 11, 2019 at 09:12:45AM +0200, Michal Hocko wrote:
> On Wed 10-07-19 16:36:58, Mike Kravetz wrote:
> > On 7/10/19 12:44 PM, Michal Hocko wrote:
> > > On Wed 10-07-19 11:42:40, Mike Kravetz wrote:
> > > [...]
> > >> As Michal suggested, I'm going to do some testing to see what impact
> > >> dropping the __GFP_RETRY_MAYFAIL flag for these huge page allocations
> > >> will have on the number of pages allocated.
> > > 
> > > Just to clarify. I didn't mean to drop __GFP_RETRY_MAYFAIL from the
> > > allocation request. I meant to drop the special casing of the flag in
> > > should_continue_reclaim. I really have hard time to argue for this
> > > special casing TBH. The flag is meant to retry harder but that shouldn't
> > > be reduced to a single reclaim attempt because that alone doesn't really
> > > help much with the high order allocation. It is more about compaction to
> > > be retried harder.
> > 
> > Thanks Michal.  That is indeed what you suggested earlier.  I remembered
> > incorrectly.  Sorry.
> > 
> > Removing the special casing for __GFP_RETRY_MAYFAIL in should_continue_reclaim
> > implies that it will return false if nothing was reclaimed (nr_reclaimed == 0)
> > in the previous pass.
> > 
> > When I make such a modification and test, I see long stalls as a result
> > of should_compact_retry returning true too often.  On a system I am currently
> > testing, should_compact_retry has returned true 36000000 times.  My guess
> > is that this may stall forever.  Vlastmil previously asked about this behavior,
> > so I am capturing the reason.  Like before [1], should_compact_retry is
> > returning true mostly because compaction_withdrawn() returns COMPACT_DEFERRED.
> 
> This smells like a problem to me. But somebody more familiar with
> compaction should comment.
> 

Examine in should_compact_retry if it's retrying because
compaction_zonelist_suitable is true. Looking at it now, it would not
necessarily do the right thing because any non-skipped zone would make
it eligible which is too strong a condition as COMPACT_SKIPPED is not
reliably set. If that function is the case, it would be reasonable
remove "ret = compaction_zonelist_suitable(ac, order, alloc_flags);" and
the implementation of compaction_zonelist_suitable entirely as part of
your fix.

-- 
Mel Gorman
SUSE Labs


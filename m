Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 823DDC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 08:44:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B0562085B
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 08:44:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B0562085B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D61108E0003; Tue, 29 Jan 2019 03:44:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CEA778E0001; Tue, 29 Jan 2019 03:44:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A52608E0003; Tue, 29 Jan 2019 03:44:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 585968E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 03:44:01 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id t7so7600854edr.21
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 00:44:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+jGlZwt+om8ffVFtx2wuPnn+GsxyjkZjUnpJkYG2xyM=;
        b=VDGrVdCf+B2bXZjQlFDJ8Da4hV3MLv7JOJWAxKWkZ803E11MUkytAlXwmDTs9xLa7i
         RjoPxFadt39rqXGci/sOkbLlrXWkt1w27jPv97R7b5pqiU3tAVGYyw9IVhgSZ95GG5+w
         adGMiKnMcaLgPUPkCigLuCzD3WgB/se010v4yzzPi6XrW3YMsQbUjpzVzqazV89jnodL
         YL4b6/iJ0VMP7bL5zerfGN1wJClnKoiXDawot5Y5yaKmRwQNCWA+0gTZBMyrXNN2Qyga
         2OHRVTbwCeWq+GKe9oomBelGXJ+ugk3Q0qJiapzayCK/rJS+nuFKFKRXvj9aTSP2f/Wa
         G7Kg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: AJcUukdDTTrFbEULjnG0kVC4TctoWfwhxzS5Q4AsRK03cAyapnV/wb+g
	OC9bZYDfIMFTMoW77lQtTF5kW5q841FkK6QggSuFcr0y/lOsANdiVMcl4PLdhdAgDmLmyhoTBWT
	riypR7n2XPl+I0Z0v961TCLWtoohoS3/oyLu3U1yH6JYThj3g39/+OdmtTcp14nI=
X-Received: by 2002:a50:8bb5:: with SMTP id m50mr24125472edm.211.1548751440854;
        Tue, 29 Jan 2019 00:44:00 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4AF/e2twXTSEpWuIcrd8vcYxffqB6bPFHoeRXfVLHsJxFol2eWOy7T5Z6srMzIPiTCwV0W
X-Received: by 2002:a50:8bb5:: with SMTP id m50mr24125443edm.211.1548751440078;
        Tue, 29 Jan 2019 00:44:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548751440; cv=none;
        d=google.com; s=arc-20160816;
        b=d4WTuHqwl+zt9Weh9snNABh4cMfaTI0S3oB6UxT5cU6Shk0SsK8rMXj2Mx6xdoSP2e
         Z+Ung2K2VP4pwLHsXWs+wOEzWHEX5HqlYc9mE2pE4MiefOtM1IfigndKqjxFb+9hKywd
         xxT0utaG8KBwISFea+S4Pzrw8JM5dowytUL3spDX31bdZbSCAuIJ2o62FrwRs9tqP0ZC
         ZOTort82HtxBSs4hhciptrixxMTTDESiX7ow7mHG76EGVBsXbDehq/uRk8TzJLQ85oiY
         A2HwzuOh7ePzwZFlIzoWaYvDXs4oRYy6UmcMOOVVCB46lsCW507IK2rBLBvXawANTwKz
         GC9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+jGlZwt+om8ffVFtx2wuPnn+GsxyjkZjUnpJkYG2xyM=;
        b=ZOMyggwcIM3CXpvIiHFbQ/qWTbAPNob9vV/CM6HVbAPluD4e9XyWr9dhv+L2mp5i40
         qPRe2+ZcN2bT6pESIWR62Y4/RuBo9GQb2EeHl5YnBiO74h1C+c9PyJZYrB2MbcYvelYg
         EKlQa2hbVlAKpsl+1Q6QGpxGkznavSiAboMOThCTWT0ZIsFZYEVgVOONUv61sqE2QO8/
         3+LboTsD4KpYw8BrThsaN9VWggnQ88sepRN58t2gCfpAQdabURa6H3Z3CDq6Aic3gWEP
         JPtc64519HNR791nKA1llGswOhLswU10d5h9svxb3WNwu6Swk9cI7JSUY9h3HCa2oiIL
         QT5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id z9si354052ejx.127.2019.01.29.00.43.59
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 00:43:59 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) client-ip=2620:113:80c0:5::2222;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 4977F40AF; Tue, 29 Jan 2019 09:43:59 +0100 (CET)
Date: Tue, 29 Jan 2019 09:43:59 +0100
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, mhocko@suse.com, dan.j.williams@intel.com,
	Pavel.Tatashin@microsoft.com, linux-kernel@vger.kernel.org,
	dave.hansen@intel.com
Subject: Re: [RFC PATCH v2 0/4] mm, memory_hotplug: allocate memmap from
 hotadded memory
Message-ID: <20190129084359.65fzc4hqan265gii@d104.suse.de>
References: <20190122103708.11043-1-osalvador@suse.de>
 <d9dbefb8-052e-7cb5-3de4-245d05270ff9@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d9dbefb8-052e-7cb5-3de4-245d05270ff9@redhat.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 25, 2019 at 09:53:35AM +0100, David Hildenbrand wrote:
Hi David,

> I only had a quick glimpse. I would prefer if the caller of add_memory()
> can specify whether it would be ok to allocate vmmap from the range.
> This e.g. allows ACPI dimm code to allocate from the range, however
> other machanisms (XEN, hyper-v, virtio-mem) can allow it once they
> actually support it.

Well, I think this can be done, and it might make more sense, as we
would get rid of some other flags to prevent allocating vmemmap
besides mhp_restrictions.

> 
> Also, while s390x standby memory cannot support allocating from the
> range, virtio-mem could easily support it on s390x.
> 
> Not sure how such an interface could look like, but I would really like
> to have control over that on the add_memory() interface, not per arch.

Let me try it out and will report back.

Btw, since you are a virt-guy, would it be do feasible for you to test the patchset
on hyper-v, xen or your virtio-mem driver?

Thanks David!

-- 
Oscar Salvador
SUSE L3


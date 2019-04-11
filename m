Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF691C282CE
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 11:32:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 69DE02184B
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 11:32:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 69DE02184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06AFF6B000E; Thu, 11 Apr 2019 07:32:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F34A06B026A; Thu, 11 Apr 2019 07:32:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD5C16B026B; Thu, 11 Apr 2019 07:32:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 884456B000E
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 07:32:09 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k8so2906226edl.22
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 04:32:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=S7X9hV7LOt+JiE4IhDf4srG1hc8OQIEY0E8eXJdN+zM=;
        b=OHr79Ubqvni1erzC67D9x80Yns4d/ireH+uc4uLvmY6lXJv4LFge/iwAMyyL5JXOuX
         f2+YcwGiGJzh9yFPMy5sGw2ChUExEbq8ffOPJcVn/QV9SGJWnOWqkppaVed0cV3t3io5
         +0lpX7ynk5rUZPuG7jY/1+cDaYbFnkJVevAfAC0nZke7erEL3PHaLB0aWQom5lcv38T4
         +LZ5viluz6RLeYb2nrkv09aKEQvV1bi71G0uktnP5ak7x3aO92TOT9JXWHc8GGR6Cz4t
         mPfQHWjgVdgcdN+XbfMun1Tt0yk9JzJ42odZowAbywIfm+pcKm4QGI+tMv7MIXZdVwAI
         +cEw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWeFHysFvZ8h9HbHMbvFmGFvUbHBxFL5IfHTA1rYR+sDw5tpxRA
	0HP1NwhqZbyhQ+SdlWeoCsvLnTx55MywIuYTpn9BF7VKNvV/NVKH/rOgTT89FllmTh6LZfr+Xcp
	ED9OU0TQOI0dWQB4pCOUW15p/VXPCxlE7sZZTrRV28lBOieS/TPiGHYX5hZgcfbo=
X-Received: by 2002:a17:906:708d:: with SMTP id b13mr27668469ejk.120.1554982328986;
        Thu, 11 Apr 2019 04:32:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy29yn86dYbBQXs1hkPLAIUk4P0r6H5NXeve/pjeMCeNKKNWJK1h4fVV9IoFpMSI9FL+LlY
X-Received: by 2002:a17:906:708d:: with SMTP id b13mr27668420ejk.120.1554982327832;
        Thu, 11 Apr 2019 04:32:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554982327; cv=none;
        d=google.com; s=arc-20160816;
        b=jwL8Mj/XOfgYMOvOnAXLsOFmCASB8LYO2PyU1z2pewXjIYnmCMTspdhr9xbfZjSPfc
         JCEjU7ARRJo8souIi+MCaV+2BYJicW2yYMcOW6EHb0JYoAJPneQ4cwooln7queDnxwy4
         qFI7khu8fBxOysgF7TDxceLCQ9vrmZkMVciLKdOnxOFIVRXTbDiXrlqLKkGzlqjpW3ue
         SvXSs0332sT0FTrELVc4tOGww76N2lH4cRspiPODmhYeSCcn1sNaJkNRQV0bB/ssB5P/
         KMefcaAYr6fjFecuAwp2RU3JlUG/5gaqEhpvy6Jc69sGhFWx0WlH1hXQjQ1C+uCWqV9o
         Z+iA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=S7X9hV7LOt+JiE4IhDf4srG1hc8OQIEY0E8eXJdN+zM=;
        b=0Ivj9XVdpESwvc2lgwt3o6Q2yi3cWGy8AQvq7BODUf0PKw3kH8/3RWxtOdQpSzg+R+
         vQ/2/ZKYJqZmysspaFPnMtzvxgfpN8/ON/7WvjSyKShEKvK9Yy4tNoWE2oiBGYZs2yI7
         CnFOBNM7K6CFG8ahm1QWf+aXuRffwzIUsHStryLogsrEcmGo+yEwDPwLFkrYAgevCK3c
         7QU6JQ4WAPioFh4Etgpu1NsF34ZJWlpN1arORAJHAL+LCBEwYKP8q0vczzKTxbW1b1tN
         ax8SK9tvzEgIszYDqOr1KWyn7rC76Nn3NF7vtnOxHtjM4JrZQA3njUg3Qx5E4GPAJieX
         SG8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f16si926711edx.29.2019.04.11.04.32.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 04:32:07 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 36B57AC5B;
	Thu, 11 Apr 2019 11:32:07 +0000 (UTC)
Date: Thu, 11 Apr 2019 13:32:06 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Oscar Salvador <osalvador@suse.de>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Wei Yang <richard.weiyang@gmail.com>, Qian Cai <cai@lca.pw>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: Re: [PATCH] mm/memory_hotplug: Drop memory device reference after
 find_memory_block()
Message-ID: <20190411113206.GU10383@dhcp22.suse.cz>
References: <20190410101455.17338-1-david@redhat.com>
 <20190411084141.GQ10383@dhcp22.suse.cz>
 <0bbe632f-cb85-4a98-0c79-ded11cf39081@redhat.com>
 <20190411105617.GS10383@dhcp22.suse.cz>
 <711db571-ee39-eb64-4551-baaa5b562579@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <711db571-ee39-eb64-4551-baaa5b562579@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 11-04-19 13:18:07, David Hildenbrand wrote:
> On 11.04.19 12:56, Michal Hocko wrote:
> > On Thu 11-04-19 11:11:05, David Hildenbrand wrote:
> >> On 11.04.19 10:41, Michal Hocko wrote:
> >>> On Wed 10-04-19 12:14:55, David Hildenbrand wrote:
> >>>> While current node handling is probably terribly broken for memory block
> >>>> devices that span several nodes (only possible when added during boot,
> >>>> and something like that should be blocked completely), properly put the
> >>>> device reference we obtained via find_memory_block() to get the nid.
> >>>
> >>> The changelog could see some improvements I believe. (Half) stating
> >>> broken status of multinode memblock is not really useful without a wider
> >>> context so I would simply remove it. More to the point, it would be much
> >>> better to actually describe the actual problem and the user visible
> >>> effect.
> >>>
> >>> "
> >>> d0dc12e86b31 ("mm/memory_hotplug: optimize memory hotplug") has started
> >>> using find_memory_block to get a nodeid for the beginnig of the onlined
> >>> pfn range. The commit has missed that the memblock contains a reference
> >>> counted object and a missing put_device will leak the kobject behind
> >>> which ADD THE USER VISIBLE EFFECT HERE.
> >>> "
> >>
> >> I don't think mentioning the commit a second time is really needed.
> >>
> >> "
> >> Right now we are using find_memory_block() to get the node id for the
> >> pfn range to online. We are missing to drop a reference to the memory
> >> block device. While the device still gets unregistered via
> >> device_unregister(), resulting in no user visible problem, the device is
> >> never released via device_release(), resulting in a memory leak. Fix
> >> that by properly using a put_device().
> >> "
> > 
> > OK, sounds good to me. I was not sure about all the sysfs machinery
> > and the kobj dependencies but if there are no sysfs files leaking and
> > crashing upon a later access then a leak of a small amount of memory
> > that is not user controlable then this is not super urgent.
> > 
> > Thanks!
> 
> I think it can be triggered by onlining/offlining memory in a loop. 

which is a privileged operation so the impact is limited.

> But as you said, only leaks of small amount of memory.

Yes, as long as there are no other side sysfs related effects.
-- 
Michal Hocko
SUSE Labs


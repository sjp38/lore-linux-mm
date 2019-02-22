Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F57EC4360F
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 00:28:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21C4E20838
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 00:28:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21C4E20838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A06908E00DC; Thu, 21 Feb 2019 19:28:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B61E8E00D4; Thu, 21 Feb 2019 19:28:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A5428E00DC; Thu, 21 Feb 2019 19:28:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 610088E00D4
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 19:28:03 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id z198so260985qkb.15
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 16:28:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=6R14OUQfhE80mk4r/xaNELNoHO3WwJDwIX09lu71D4M=;
        b=H+tSJzZkjOQu62eIpOxJvUGWkMafR21nY4+C4pQLjRC9e1JGA+Tj/xzIZny/mJ6LdK
         KRobzpv8IOjff+fN2qpzPqNxb6gU+aoSkVysejEBCzCxUKb4rAHhpjKdcOF8QlrjdW5T
         +IujPj094AAnFNGtHCxv6s/Yvkjg+H1G/MSlz6K51T+Z/0UiP7Om17M6jRJbPXe6TCQb
         Jl2li4sLjBGpZ0vvz8kTf1kAaiG5hvZadHq6eiSlDLhdrQueRCCDmZFrjgSsPP9GhdNN
         skBV28G2bGfqOXKdRIKO6THU7ceQpf+STRRcreXXz1krksdUwSArFwDVcwTKN0jHgxDv
         g+Bg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAua49d7B0ZUn6MEOUMb4gu6oV/DrB1WhuREgK528L/UAvCFOnAW0
	hP6qD3uaSfZF4YU0nURRK5TfhFwahVEj2/WjtsgklexacIUWiJ4tT88WhQWOEAZwFxLYxJ2TolF
	Q8v5XnXjgZuVoim7OL+LCYLv2kQotMzSrXTCKml6AHd74+an5KvkqF0x+gyTKyqsBFQ==
X-Received: by 2002:ac8:2e19:: with SMTP id r25mr1014023qta.0.1550795283130;
        Thu, 21 Feb 2019 16:28:03 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaiK2xZr2G1AW75peTXLKjSthsEGgqVJij90qldzatEHscNtgF9Ua+ELoyzcZ+1pnf/Qtt5
X-Received: by 2002:ac8:2e19:: with SMTP id r25mr1013999qta.0.1550795282506;
        Thu, 21 Feb 2019 16:28:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550795282; cv=none;
        d=google.com; s=arc-20160816;
        b=GnVivo/CHlvTXluohPH1H+X3xOKh+1VxTPBiQZlb+jSKY1f10LKPeSzKHozI7o1Opb
         cIzQmvQ2rsYjqH3uCFnywIgOqdy8fi8C8o8h5k25n8mrT5pCvNGOc4VVPgAu+/MSSxk2
         61VDxPFKaguVs+SJ8dyDfeq4bTfgzV2D95anlNdC8qfuhcf8AoEw2NlY+dvyJkVMM0lE
         NzlduTVgtnIx6mmrCCoOwjnlxq+S4R2BoHE1DKUKcdzAh7vYJXf/Raccxq41uCPGZvUQ
         Vy9fwZ0kyR9o6DmZx2zEZld2RIU2raV86crtPPZAcoxWDW7vPJW7D6qjZFkggAI2A4Hh
         yCzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=6R14OUQfhE80mk4r/xaNELNoHO3WwJDwIX09lu71D4M=;
        b=bG8/NWBF6Z3kOKaWjnNcZDT0aqi5bkWffkohqdQ/qXyHjFmaGCgFqJGz6smtIvygvE
         DJb8sSXNBSd3YSAL77CX5D6a6bOb9nFWpHmXWKFlpKulPqC3RpBqqpvpmbWntI59KA+b
         TQKprQyzWmsvyJESDnJfOzklFv2x/andvZ/qu9n2p7HXV+pDhTTbeKbxSPv/5RL2JW82
         JpPPWB4pWnsqRxBZZ91iBzqw+FNawzde8GWYxQVe7KZ76ER9Tp2p/K1OzvxcSTnzsCyL
         1d2iJiYFvZPPUkGIGbXeQJOYPSKLzQH74b9+5GFQo0C0xlg+aadixePuX98pPSw2i08F
         LT0w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i67si206271qkb.239.2019.02.21.16.28.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 16:28:02 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 349273002DA2;
	Fri, 22 Feb 2019 00:28:01 +0000 (UTC)
Received: from redhat.com (ovpn-120-13.rdu2.redhat.com [10.10.120.13])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 5D28760139;
	Fri, 22 Feb 2019 00:27:58 +0000 (UTC)
Date: Thu, 21 Feb 2019 19:27:55 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Adam Manzanares <Adam.Manzanares@wdc.com>
Cc: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"willy@infradead.org" <willy@infradead.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"yang.shi@linux.alibaba.com" <yang.shi@linux.alibaba.com>,
	"dan.j.williams@intel.com" <dan.j.williams@intel.com>,
	"cl@linux.com" <cl@linux.com>, "mhocko@suse.com" <mhocko@suse.com>,
	"dave.hansen@intel.com" <dave.hansen@intel.com>,
	"jack@suse.cz" <jack@suse.cz>
Subject: Re: [LSF/MM TOPIC] Page Cache Flexibility for NVM
Message-ID: <20190222002754.GA10607@redhat.com>
References: <85ddda85755bf15ed2e56bce21f711ae8154d304.camel@wdc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <85ddda85755bf15ed2e56bce21f711ae8154d304.camel@wdc.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Fri, 22 Feb 2019 00:28:01 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 11:11:51PM +0000, Adam Manzanares wrote:
> Hello,
> 
> I would like to attend the LSF/MM Summit 2019. I'm interested in
> several MM topics that are mentioned below as well as Zoned Block
> Devices and any io determinism topics that come up in the storage
> track. 
> 
> I have been working on a caching layer, hmmap (heterogeneous memory
> map) [1], for emerging NVM and it is in spirit close to the page
> cache. The key difference being that the backend device and caching
> layer of hmmap is pluggable. In addition, hmmap supports DAX and write
> protection, which I believe are key features for emerging NVMs that may
> have write/read asymmetry as well as write endurance constraints.
> Lastly we can leverage hardware, such as a DMA engine, when moving
> pages between the cache while also allowing direct access if the device
> is capable.
> 
> I am proposing that as an alternative to using NVMs as a NUMA node
> we expose the NVM through the page cache or a viable alternative and
> have userspace applications mmap the NVM and hand out memory with
> their favorite userspace memory allocator.
> 
> This would isolate the NVMs to only applications that are well aware
> of the performance implications of accessing NVM. I believe that all
> of this work could be solved with the NUMA node approach, but the two
> approaches are seeming to blur together.
> 
> The main points I would like to discuss are:
> 
> * Is the page cache model a viable alternative to NVM as a NUMA NODE?
> * Can we add more flexibility to the page cache?
> * Should we force separation of NVM through an explicit mmap?
> 
> I believe this discussion could be merged with NUMA, memory hierarchy
> and device memory, Use NVDIMM as NUMA node and NUMA API, or memory
> reclaim with NUMA balancing.

What about cache coherency and atomic ? If device block are expose
through PCIE then there is no cache coherency or atomic and thus
direct mmap will not have the expected memory model which would
break program expectation of a mmap.

This is also one of the reasons i do not see a way forward with NUMA
and device memory. It can depart from the usual memory too much to
be drop in like that to unaware application.

In any case yes this kind of memory falls into the device memory i
wish to discuss during LSF/MM.

Cheers,
Jérôme


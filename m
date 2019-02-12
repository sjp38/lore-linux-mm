Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 802EDC4151A
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 17:31:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 465B120821
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 17:31:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 465B120821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF9748E0002; Tue, 12 Feb 2019 12:31:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD06C8E0001; Tue, 12 Feb 2019 12:31:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE9148E0002; Tue, 12 Feb 2019 12:31:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6F70D8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 12:31:41 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id l76so2984304pfg.1
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 09:31:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=iVxv0FmMpSbDb7ZrCvAo83ah/Aycwam3cI07JAEHCtw=;
        b=a5/2p6YJf7hGV9EI3MwM1iXJxo3FFCXVZ7506uNYaQT9zHa5T7xEiZMoGZ1VcBa154
         NnV6x250yWXi+SuWN5o/+6vO5Kajy+3KnVFZmcxsOra3Xtq3we8MsuW0TAhM73kyDDLm
         Zg84saqynZtFCw+U8OjQr8+6fNX76iiT3kIX2t9rh5o5HZ1bTWR9LHmj8bfsgKBevQC3
         /Z8U1S4mxrNrEgoA930dUsxWtYp9z8tKdYXVwRuKauXjkYfsQFdl1y8OuqvbDyscG9RQ
         oL0QfR9SKK9aLx5DuyQHqBlUO+yQPkqUBSFTie+KCUq+oNrfdgaxp0H0mxhQoZZiJgsB
         9oQw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubaNKmffYfMc4Yk1Kz5n7ovBsVDoMP9ajTi4yQQo/sWT9pLFO05
	DIS5/RHr3QUEK+NBlRX56WxHfqKWPZvMwKeZnuehMpVBoEBsB+yspljKMp0hJOXU+bQAUN7diLl
	xym08jiT/vdqm7DRyr8HZDD3T6Dd29lXCdkGBpigNkN2gq1b13yrZQZhcts68jaCKHQ==
X-Received: by 2002:a63:d347:: with SMTP id u7mr4538131pgi.383.1549992701093;
        Tue, 12 Feb 2019 09:31:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYiJ+nVorn6vzQA90Kn4RwkJkrORwI+T10TzZlDcwJFKeDJQ53Ffcqqu3Z3TVhjqIpSM/VK
X-Received: by 2002:a63:d347:: with SMTP id u7mr4538087pgi.383.1549992700351;
        Tue, 12 Feb 2019 09:31:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549992700; cv=none;
        d=google.com; s=arc-20160816;
        b=urnCpgPjPiGS8zvDug0fUnV1IYw467pFeZX8RPCW5CLNfBcrI3gwi6uglo+WvM8gOP
         a8eYjIkpxcDkmoomZEs4JpWlGgvCiOoRi7ursIc/MKrRxelvpdVWnxgd4KK3asJ4g0hz
         wEHKE36BquW2YIQbrKXPfh2eLAvDbof5VZzFSrHvgqzrLOCfIVCqytYBhYNrrZpeZUqR
         hv8JvCBKWBkPGt6pGkg9CyemSUGJJ7KaYoduWtoe9uF5GZ3ZAVQYAjw1opbApVKtNUxJ
         dLngmVHVwO4M58hW9KJ2waPOzrWCmBOoIF5ukAC+KD6DdRpcsd1n45/p5yVw/qUl/REh
         2AEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=iVxv0FmMpSbDb7ZrCvAo83ah/Aycwam3cI07JAEHCtw=;
        b=s9KDOQtVvsGY8dkOCOnMt9xQ5g7d/tJCvjUEYfa6dFVIrr9XB+chQYXBVLy6lFR5E9
         lGZRYeFhqXnZ1iAhbAXwya6L/7IWGHPLe1DLt0sfPV/8YseVh5HDUTrTUv3Er5f1eAqw
         oznIOP0agVojuxLxVbKS4KE1cU8FK8QMgtK8WaQIFRWWyhJLm2gJVl1NHKBTKFMMgHdi
         l5ZFau4Ju6mGbiWzXHhknap3mSNCBie6Tp6R1Ndb4otWQlnvG2P5y4D0KiSxnkV70V4/
         68dO0fmAObPI0IjRJ4p0Qgjtg/3C8HC9tnLmRtF0HJL4k2pupS7V+1p5Zd8gGPFkXrli
         IPoA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id h189si13535426pfc.211.2019.02.12.09.31.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 09:31:40 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Feb 2019 09:31:39 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,362,1544515200"; 
   d="scan'208";a="114355454"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by orsmga007.jf.intel.com with ESMTP; 12 Feb 2019 09:31:38 -0800
Date: Tue, 12 Feb 2019 10:31:20 -0700
From: Keith Busch <keith.busch@intel.com>
To: Jonathan Cameron <jonathan.cameron@huawei.com>
Cc: Brice Goglin <Brice.Goglin@inria.fr>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rafael Wysocki <rafael@kernel.org>,
	"Hansen, Dave" <dave.hansen@intel.com>,
	"Williams, Dan J" <dan.j.williams@intel.com>
Subject: Re: [PATCHv4 10/13] node: Add memory caching attributes
Message-ID: <20190212173120.GD6176@localhost.localdomain>
References: <20190116175804.30196-1-keith.busch@intel.com>
 <20190116175804.30196-11-keith.busch@intel.com>
 <4a7d1c0c-c269-d7b2-11cb-88ad62b70a06@inria.fr>
 <20190210171958.00003ab2@huawei.com>
 <20190211152303.GA4525@localhost.localdomain>
 <20190212084903.00003ff5@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212084903.00003ff5@huawei.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 08:49:03AM +0000, Jonathan Cameron wrote:
> On Mon, 11 Feb 2019 08:23:04 -0700
> Keith Busch <keith.busch@intel.com> wrote:
> 
> > On Sun, Feb 10, 2019 at 09:19:58AM -0800, Jonathan Cameron wrote:
> > > On Sat, 9 Feb 2019 09:20:53 +0100
> > > Brice Goglin <Brice.Goglin@inria.fr> wrote:
> > >   
> > > > Hello Keith
> > > > 
> > > > Could we ever have a single side cache in front of two NUMA nodes ? I
> > > > don't see a way to find that out in the current implementation. Would we
> > > > have an "id" and/or "nodemap" bitmask in the sidecache structure ?  
> > > 
> > > This is certainly a possible thing for hardware to do.
> > >
> > > ACPI IIRC doesn't provide any means of representing that - your best
> > > option is to represent it as two different entries, one for each of the
> > > memory nodes.  Interesting question of whether you would then claim
> > > they were half as big each, or the full size.  Of course, there are
> > > other possible ways to get this info beyond HMAT, so perhaps the interface
> > > should allow it to be exposed if available?  
> > 
> > HMAT doesn't do this, but I want this interface abstracted enough from
> > HMAT to express whatever is necessary.
> > 
> > The CPU cache is the closest existing exported attributes to this,
> > and they provide "shared_cpu_list". To that end, I can export a
> > "shared_node_list", though previous reviews strongly disliked multi-value
> > sysfs entries. :(
> > 
> > Would shared-node symlinks capture the need, and more acceptable?
> 
> My inclination is that it's better to follow an existing pattern than
> invent a new one that breaks people's expectations.
> 
> However, don't feel that strongly about it as long as the interface
> is functional and intuitive.

Okay, considering I'd have a difficult time testing such an interface
since it doesn't apply to HMAT, and I've received only conflicting
feedback on list attributes, I would prefer to leave this feature out
of this series for now. I'm certainly not against adding it later.


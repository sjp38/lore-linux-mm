Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25581C10F0B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 10:46:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C75F42148E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 10:46:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C75F42148E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2DC3D6B0008; Wed,  3 Apr 2019 06:46:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 28B836B000A; Wed,  3 Apr 2019 06:46:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 17C376B000C; Wed,  3 Apr 2019 06:46:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id BD8A86B0008
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 06:46:07 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id m31so7317689edm.4
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 03:46:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=libD4G5gl/Vs82BWT6B4NoK+k1suve++7qa8I4Zh880=;
        b=Un1j76aDN+PAbV2exnBBwXvA2JbIBjXCTV+KXxtoUE/2AMQpjM3YqwW7z6tL/QITtD
         mo3mDZ2VGHVX6NO69JJEU+gpn3oe3qsQqPYjc5bKYcT0xXI1sNG2AvWQwdeM6JwGS/oi
         ZH0kbsgchj7OFmzJHoS6iZ30BxZmrf1SH6+gAYEiDQFb4jYg5Tfdi6569EtqyM32MNYr
         1FMdwhleDWESKL+iPozgrTw4p5XLJNSoEKEhppmOFyUgCGdt4kNXsGCVVvS0go5PA4CC
         VBKE/UDaOpcLzZYVlMxVa11XUQ6op3xnt2dcdOilgqvBlglCLKRasbw9enapqhdVbyvK
         i0oA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAV1KdWSequSiD37Vv4Ppkf5XFcihLJnxVPa0Qq7hv7/VDmfzjHl
	KPAjfwYsd9aM30zzYItofnsUPEPw6Kk0GxZMqOZcMVfQEgy/6b1bTCL5tYp/y8fPu6nVtTQWDb1
	gv2E65HILQmaAqrzeVxKyCnC0LLZcFRzk2HH+qsd8N0KXZ585d45aolrRhet0IUU=
X-Received: by 2002:a17:906:f0f:: with SMTP id z15mr43833284eji.125.1554288367300;
        Wed, 03 Apr 2019 03:46:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz7ISGOOELbck/gvvmjBYjhLfxLpS2GhoaxbkyTM1VgsOayMHDEQPJBWzYc0EZhk1oFG3Uo
X-Received: by 2002:a17:906:f0f:: with SMTP id z15mr43833246eji.125.1554288366268;
        Wed, 03 Apr 2019 03:46:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554288366; cv=none;
        d=google.com; s=arc-20160816;
        b=CwgHTwaoq7iqXXhiVx1mGEX2yZK7occye6JrwWPOEB53EB2YOQSvCchLKMjPAl8HbN
         MUboJun0CI59gn7iC+wF+zFK5kURKcoDqnMyKwz+EE+m8fqy5bc+5ZR2Rr/ejfPDOCvo
         h7VMnsTrBYWelw4hzvTI9bJ09FOs0EbyCNG+VW9PO7zPZAt/uSCgj/AtDrXIkr+qDYIA
         jMCfgE0zkjNJDmEM0xxLczmRbxJ+8E7vBqBT/nVdTyvYvs74EDs2PN3CyyOeasWevvZN
         ELv9+SwpIYQJGzOmAedCv+JGdDc3WbUr7h0b5cXbY05M2hYYGjTmIigk4u2DP6bfTynO
         ukOg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=libD4G5gl/Vs82BWT6B4NoK+k1suve++7qa8I4Zh880=;
        b=ZZ69LWdJxFxUeiUjuIoYHBZZ0KnwUWZjSRrHmMiR76xgTiZNegbuKO4n4I7AnXMcHy
         njpVSd0QHffYYxPb18ruC3kfro50SuyRyhyWAeIycy214n1cSehc8SmtEPkvPx1v1HAv
         Nli8EaH4tXbDWRmg7aPmSklpgJYzDs5wnG1S7NP33qkoKAaJDLj64Sz22Wmfy5dnVyrZ
         cIWanCQhVOhXNxQT3eM/zufea4h8Cc57Xq6U3VG5Z1ENQiQ9xKZ0hvWxJY1EkvvCGrUk
         pLf6ui17znJwlDvZJ7tGtt5n6mglFqshBSo3vcQYI3NaSF0gx3qYavRWWdzfu3fPhSSb
         cqmw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y13si5214550edq.367.2019.04.03.03.46.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 03:46:06 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E6B22AF4C;
	Wed,  3 Apr 2019 10:46:03 +0000 (UTC)
Date: Wed, 3 Apr 2019 12:46:02 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: David Hildenbrand <david@redhat.com>, akpm@linux-foundation.org,
	dan.j.williams@intel.com, Jonathan.Cameron@huawei.com,
	anshuman.khandual@arm.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH 0/4] mm,memory_hotplug: allocate memmap from hotadded
 memory
Message-ID: <20190403104602.GJ15605@dhcp22.suse.cz>
References: <20190329134243.GA30026@dhcp22.suse.cz>
 <20190401075936.bjt2qsrhw77rib77@d104.suse.de>
 <20190401115306.GF28293@dhcp22.suse.cz>
 <20190402082812.fefamf7qlzulb7t2@d104.suse.de>
 <20190402124845.GD28293@dhcp22.suse.cz>
 <20190403080113.adj2m3szhhnvzu56@d104.suse.de>
 <20190403081232.GB15605@dhcp22.suse.cz>
 <d55aa259-56c0-9601-ffce-997ea1fb3ac5@redhat.com>
 <20190403083757.GC15605@dhcp22.suse.cz>
 <20190403094054.jdr7lxm45htgcsk7@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190403094054.jdr7lxm45htgcsk7@d104.suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 03-04-19 11:40:54, Oscar Salvador wrote:
> On Wed, Apr 03, 2019 at 10:37:57AM +0200, Michal Hocko wrote:
> > That being said it should be the caller of the hotplug code to tell
> > the vmemmap allocation strategy. For starter, I would only pack vmemmaps
> > for "regular" kernel zone memory. Movable zones should be more careful.
> > We can always re-evaluate later when there is a strong demand for huge
> > pages on movable zones but this is not the case now because those pages
> > are not really movable in practice.
> 
> I agree that makes sense to let the caller specify if it wants to allocate
> vmemmaps per memblock or per memory-range, so we are more flexible when it
> comes to granularity in hot-add/hot-remove operations.

And just to be more specific. The api shouldn't really care about this
implementation detail. So ideally the caller of add_pages just picks up
the proper allocator and the rest is completely transparent.

> But the thing is that the zones are picked at onling stage, while
> vmemmaps are created at hot-add stage, so I am not sure we can define
> the strategy depending on the zone.

THis is a good point. We do have means to tell a default zone for the
regular memory hotplug so this can be reused based on the pfn range
(default_zone_for_pfn).
-- 
Michal Hocko
SUSE Labs


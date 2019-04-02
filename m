Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7830BC4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 08:28:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 245972084C
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 08:28:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 245972084C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 709AC6B000A; Tue,  2 Apr 2019 04:28:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6DE7D6B026E; Tue,  2 Apr 2019 04:28:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5CE656B026F; Tue,  2 Apr 2019 04:28:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0717D6B000A
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 04:28:23 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id p5so5521754edh.2
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 01:28:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=pM2xwSphupg6rXDQBeNmtCSGa3JvGpdRybF7NUiSisc=;
        b=nZb4RVcTwhVADssMy80qjKZdmNGNZNTQEj/Moi4BBASK8rDpa/DRWT23Pcrgl1Qkwx
         fi2QNMHof6jM3X3mJJnofwOucDwKSuXQHlaSgufAqNE7TSlJKT0gqar9mcDQaZUTUrb7
         TxAaXRB2fyaW6Dlbj37kaWIIf2gvgP05912+sMAOSaaZyzc+t+g1coA973ECB2SKAd0y
         RKqyOGtAggYObr93u6fxIevZuP8EQ3oJjnspiEOt4KXXusZhDVkb/+tcdY4XjgQ1QTGs
         RGnG7yRogo/Tv5ytj/s04zb1wC8+emXVfUpy46zt0AjoiSll/7N/nSI3+N8fWXQj4m+e
         skZg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVvN2Rb72x9U3qq3tz5EIoZoaWW7oxjm2Dqhp/9NA1/pIF4yeTI
	MbKQEHBpY4vMpXJWwyWTBH2syH39NmywARKo17QelFSWM8Y61WmbBOAxjewgiXO4XHBH6r2Mr2O
	EMLwAJFFFJPa/SEezBCRk6FqDPXIMLbTtwgARS0Rktlnpeg8K5YvWTZxZzmiKrWo=
X-Received: by 2002:a17:906:6d58:: with SMTP id a24mr33034747ejt.195.1554193702498;
        Tue, 02 Apr 2019 01:28:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzo66bt9BtKGke6LINqpX+6elqWMDwN16habIrYKJ6P64hF8944jC/SYiJVm2JdsNeoArmB
X-Received: by 2002:a17:906:6d58:: with SMTP id a24mr33034698ejt.195.1554193701541;
        Tue, 02 Apr 2019 01:28:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554193701; cv=none;
        d=google.com; s=arc-20160816;
        b=DuPZgyAFTesOajW/qoNuvGu2Cnvpl6NuLxrUi4cwJoVFt/wevKcFkeDsyuwblQk+KR
         vL18rS0psiJVekkUXlLMF/DakHbUVwYAwc47WrGRkC8Dx2ZIPqDeoAUuDbV7nHJV9uAf
         6zCx/nJKboeG4F2Tnjx0FEikzXumfGwfOHZSiigiKpCaO3a0dtfFp65C/q6DayyxgvXP
         wHQW5QytE059u8Sn7Ij54sD7sEkutLtYVAurV5YYaJb7qMdfQCQeuVTc3l/ThKQQ1xgk
         XTW6YJRVlbRZIfJ4L0kXcfhy+Y9GNNs94RUYYTCuJboJtJnS0VIdO3j9SCjw8qBtCP/d
         HHMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=pM2xwSphupg6rXDQBeNmtCSGa3JvGpdRybF7NUiSisc=;
        b=orlHXtj+4Ss16jTYJSzWxpce/EeLYCKael5MvupRLXFtLZ/tpP9vjUMHlE2kZXrJdR
         rznqKgFCFl8lS61+454iPWqI7phuozn0czdGlnSi6ZtKKCg4vhhWBrmv5FI4PVIeXdf3
         9QAc1FvVmKZ3q4mf8r9xuEHljZHb9qZVN2m9uVKUkwlSQS35CDePLW66XzDQdftj1O1U
         wPaHtjaSRyQFjVYi0COwDQh/3N1eEv0ZDToD6jCZSE9cxZk7kUiSx0Ug0fxt04U/+9/G
         yS4w6uOyOMLpG6A37X3K5DkjSj3yd4mjkg2cBcfAjKBS8o9Z/VAAzde/dex5pIJPtE/V
         61Tg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id s53si5392753edd.432.2019.04.02.01.28.21
        for <linux-mm@kvack.org>;
        Tue, 02 Apr 2019 01:28:21 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) client-ip=2620:113:80c0:5::2222;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 6D7C047BE; Tue,  2 Apr 2019 10:28:15 +0200 (CEST)
Date: Tue, 2 Apr 2019 10:28:15 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Hildenbrand <david@redhat.com>, akpm@linux-foundation.org,
	dan.j.williams@intel.com, Jonathan.Cameron@huawei.com,
	anshuman.khandual@arm.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH 0/4] mm,memory_hotplug: allocate memmap from hotadded
 memory
Message-ID: <20190402082812.fefamf7qlzulb7t2@d104.suse.de>
References: <20190328134320.13232-1-osalvador@suse.de>
 <cc68ec6d-3ad2-a998-73dc-cb90f3563899@redhat.com>
 <efb08377-ca5d-4110-d7ae-04a0d61ac294@redhat.com>
 <20190329084547.5k37xjwvkgffwajo@d104.suse.de>
 <20190329134243.GA30026@dhcp22.suse.cz>
 <20190401075936.bjt2qsrhw77rib77@d104.suse.de>
 <20190401115306.GF28293@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190401115306.GF28293@dhcp22.suse.cz>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 01, 2019 at 01:53:06PM +0200, Michal Hocko wrote:
> On Mon 01-04-19 09:59:36, Oscar Salvador wrote:
> > On Fri, Mar 29, 2019 at 02:42:43PM +0100, Michal Hocko wrote:
> > > Having a larger contiguous area is definitely nice to have but you also
> > > have to consider the other side of the thing. If we have a movable
> > > memblock with unmovable memory then we are breaking the movable
> > > property. So there should be some flexibility for caller to tell whether
> > > to allocate on per device or per memblock. Or we need something to move
> > > memmaps during the hotremove.
> > 
> > By movable memblock you mean a memblock whose pages can be migrated over when
> > this memblock is offlined, right?
> 
> I am mostly thinking about movable_node kernel parameter which makes
> newly hotpluged memory go into ZONE_MOVABLE and people do use that to
> make sure such a memory can be later hotremoved.

Uhm, I might be missing your point, but hot-added memory that makes use of
vmemmap pages can be hot-removed as any other memory.

Vmemmap pages do not account as unmovable memory, they just stick around
until all sections they referred to have been removed, and then, we proceed
with removing them.
So, to put it in another way: vmemmap pages are left in the system until the
whole memory device (DIMM, virt mem-device or whatever) is completely
hot-removed.

-- 
Oscar Salvador
SUSE L3


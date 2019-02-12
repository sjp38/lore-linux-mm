Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9227C4151A
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 14:50:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E03D217D9
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 14:50:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E03D217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 100A68E0002; Tue, 12 Feb 2019 09:50:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B0EC8E0001; Tue, 12 Feb 2019 09:50:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F0A698E0002; Tue, 12 Feb 2019 09:50:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id AD35E8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 09:50:38 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c53so2536556edc.9
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 06:50:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8SuJnNyUhdZ2CQRDhvpwMgzST6C2DXqwb4Z0bvJyi+Q=;
        b=e4DTjZ8WOwg2jqXw3cUyoq9C3WzXVIi2LYSUUPdLWwUV68K8oddyFj8y6b8ghrJdi4
         nqPkwPWoskF4Rs2yn2OvdhXS6Vy0efsr9FniSPHCnRs9JGUTWCzWjFywJz8LVnTv4v9Q
         rg766ZH+5suvpp59mBL51wtCqLTjrKVxe8Krty2TPRU1qR+XCohtQsv7+/Rs3hmtsSDb
         e1ENwTKQgZhvWdESoHdpfuN6meaBjTeVHb/0S42+n6xQ19QvEKbCGOIqZJwcD+eo5kzV
         M6daCW0LGPySCJXvOqBnfz7CaS9m4GCuZrAXG9gsJCtJpnGTOykDz1NVACjN88C0JQ4t
         BFkA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: AHQUAuYWeDu0CSPl4Jvpr6a268YxvDUeHf8K9Gp2hBd9KW/dhy3U+EaU
	se497TIjy0Gi/W1N9RXwiLKBz2EyaKqI6Zivcnh8UyliH9rrwZrzAXwAYGvlO7etMxC58sOI8L8
	Ou6M0SZnzsCnPnRqq9aTcwzQVFxuvo2dzbglaE4kDXOPX2aTymNoOh7cavaEnuA301w==
X-Received: by 2002:aa7:d3c3:: with SMTP id o3mr3479196edr.33.1549983038175;
        Tue, 12 Feb 2019 06:50:38 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbcFdCJp9z2xMVH7kjZdcBCYcaB/ZXHvCFlyrOllJK0pCdxAl62t6WQ2gTTbSSoz+20VI8q
X-Received: by 2002:aa7:d3c3:: with SMTP id o3mr3479139edr.33.1549983037327;
        Tue, 12 Feb 2019 06:50:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549983037; cv=none;
        d=google.com; s=arc-20160816;
        b=dMk0eoLHjKcSzaAbAbqisVklEYPsjIPX0GqOo2KvgR4u1ezJxdGiN691NwxRn289yi
         AzdfnaXLo1PtUBGU/vHCM+AOxb+a1GwueVwaZhPbYwBqRBhv7HALZXkJvWBjASxLd2ob
         yowp2EVojfK+MizoevAgFUE3RMJ3AoVnp+PaGJ86lnm4wPtkyZJplsP+T7JZfbRBK20O
         L/vwMsd0e2c5JB364Ow4c2RayPXU+FYIXulTf9sm5m+UmkncB0xgDaz0w1CuQoPH8qUJ
         fhB2sOl4F6If5s28ceiFBxpxk2IWg0/g+zxI5+EtNi0IdTsZm0kguyTzet5lZpGXAkn3
         V7+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8SuJnNyUhdZ2CQRDhvpwMgzST6C2DXqwb4Z0bvJyi+Q=;
        b=nsCqtW5XSfBUKEpisSeJs/VE5ildIEnVS6WAJ+trUYm+IA+HWz4suVesqOKP41B9Nz
         vie9a1oE7BqOA7twUR22slG8zr8I4a80goU7Wo98n/k19FCRjBL34CiLCLjxSMwZOtK/
         rh61DAG/m2sDbIUpAdiVDJVaihtFZHFACopK+TW+cDG3Ggp2EqtalYdEmKTR3ZQ6ufrg
         WCi1KdQGGqIJ6GcLlFDNji9cljkbXwJ6d05fAZoL8aT9yutPvSw3ZrhDOe1C0PfTlCF9
         llBef1sbrUJG6/rAVhrZd3kFAlR9FTROHHIl3MCx8nqpv1ng7oRIw5HOPOoSTSx4RjOA
         iqyw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [195.135.221.2])
        by mx.google.com with ESMTP id f8si319416edb.188.2019.02.12.06.50.37
        for <linux-mm@kvack.org>;
        Tue, 12 Feb 2019 06:50:37 -0800 (PST)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 91D474244; Tue, 12 Feb 2019 15:50:36 +0100 (CET)
Date: Tue, 12 Feb 2019 15:50:36 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Michal Hocko <mhocko@kernel.org>
Cc: Shameerali Kolothum Thodi <shameerali.kolothum.thodi@huawei.com>,
	Jonathan Cameron <jonathan.cameron@huawei.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"dan.j.williams@intel.com" <dan.j.williams@intel.com>,
	"Pavel.Tatashin@microsoft.com" <Pavel.Tatashin@microsoft.com>,
	"david@redhat.com" <david@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"dave.hansen@intel.com" <dave.hansen@intel.com>,
	Linuxarm <linuxarm@huawei.com>, Robin Murphy <robin.murphy@arm.com>
Subject: Re: [RFC PATCH v2 0/4] mm, memory_hotplug: allocate memmap from
 hotadded memory
Message-ID: <20190212145021.2bf2gmgprcvzkuq4@d104.suse.de>
References: <20190122103708.11043-1-osalvador@suse.de>
 <20190212124707.000028ea@huawei.com>
 <5FC3163CFD30C246ABAA99954A238FA8392B5DB6@lhreml524-mbs.china.huawei.com>
 <20190212135658.fd3rdil634ztpekj@d104.suse.de>
 <20190212144242.GZ15609@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212144242.GZ15609@dhcp22.suse.cz>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 03:42:42PM +0100, Michal Hocko wrote:
> Please make sure to test on a larger machine which has multi section
> memblocks. This is where I was hitting on bugs hard.

I tested the patchset with large memblocks (2GB) on x86_64, and worked
fine as well.
On powerpc I was only able to test it on normal memblocks, but I will check
if I can boost the memory there to get large memblocks.

And about arm64, I will talk to Jonathan off-list to see if we can do the same.

Btw, in the meantime, we could get some parts reviewed perhaps.
-- 
Oscar Salvador
SUSE L3


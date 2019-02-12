Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 605F9C282CA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 13:57:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26C8020821
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 13:57:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26C8020821
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AEF608E0002; Tue, 12 Feb 2019 08:57:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A9C978E0001; Tue, 12 Feb 2019 08:57:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 98D858E0002; Tue, 12 Feb 2019 08:57:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 54B3E8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 08:57:01 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id 143so2181994pgc.3
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 05:57:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=G1nh9RbHpUmPcgmQsGpvZi0ugxM4T8zzjx9immFvgSg=;
        b=beYuTbymg8434RPu7OdsS2E7t4SzeloT/kOz3N+gysN8wzhnFfCr7X7zj+DQGRUkyh
         JD9ltuRIxdlXR3/c3OGGhFtMEj13KOh79W30HpPtlNeDdsJtC5TpDVa+3EhQyjSoiBso
         zuQbxWi4g0j4k0TyzjbO/eW/8TDSF3IHN4ibWjSKPuVfaBZtqjlEF0+LhCsOAtgPcoOv
         RJiugCHUydvZ4QerA3AbOA6zPyPSU6pWLX4UV4fGlAv12LD+0MfnvN6n0DBm/XZVU3Rh
         y5coG1eakHwVoFEQ5K7IKyfkbmYKXhLg0HtszDsR0+ov88Mb3lNKGqcaITG6yFEvPwKx
         RuYw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: AHQUAuYEa7tEbrbybwPkGcRLSETqvIistXFz4wAJrB40uKlKuU+HnjwA
	awr8HYOf0wpTw1m4RdCa0c+lajC5QuWn6g7aAecoBvDtV7McCX2Ej7KqyEdCoK5SBI1FWic4ZRY
	yvaipmZcHZ4haSGJsdp46lumLwWwl1vNEDYKo68gXyag9YeKEefqLcYdLRjvDEoM53g==
X-Received: by 2002:a63:164b:: with SMTP id 11mr3764165pgw.238.1549979820910;
        Tue, 12 Feb 2019 05:57:00 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib0en7zvPc6SM+ZaHebhP2vwIWOZll26t4160Kv7kpmHhJ8NstNpOKG873kHk9u3wdib2Ag
X-Received: by 2002:a63:164b:: with SMTP id 11mr3764128pgw.238.1549979820156;
        Tue, 12 Feb 2019 05:57:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549979820; cv=none;
        d=google.com; s=arc-20160816;
        b=v36Fg8tC3BK2zHvA5utNDDxhtNTQZn9xYyPgUkdqYfc7uMtSRHjiq5WjF6FrL7tlhf
         nHyVe/rtaPHKcQpeE5YxNFRtbEZWTTBVekRAmKAUtBRDIA5lNpZRcPsHCW4LJpDz/mrq
         LayGum2kLFO+FcVzU1ObKr3n/XdbDETv9BigfVSiiE01w3E7q2ffhMFoWjWB++l5c+n4
         lEKVu4vr+z2SvUllmxTFAvp0hwXprtuaUI33cruRquhcypZcDUIvX+dt7qANgxcx16xe
         xPJaHQj8BkinTy8qjrhVnrM2ClS8t46iCLBMgZX+Y3neS+UI6DfBPP/QtshUOLLQmHFK
         8skw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=G1nh9RbHpUmPcgmQsGpvZi0ugxM4T8zzjx9immFvgSg=;
        b=G61eUHEg7hpNtKUUzW/ueLv20HP8uVyC6Hj7eIiBOBjEK1OictxOOhrZlUSIjQE7QZ
         Hd2tlZbHw6QCtkt0ZlF8pPTkhOw9ZfCjAiI0PMeOEo5OyQ7Bef8Q6lW2lQW0r8l31lW9
         uMRKq/Jm48CtCxHbf9TKkommB7I9WSwhnocSphdSwf+2sN0MozMzI2fmi60SbQHv3S/j
         tK9SyeF4EF02yegmb2k4VnxX24CjWKhLYl19sFBPpoNczeErTSI+Ix8uCr/xWAJ/1Ax0
         yA5Xe/y5mqOLLVYhA012xUhOrkdR6CikDvlNeDEhquS/lakkev3TWNU38kZmAvNcQeDX
         1hPg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [195.135.221.2])
        by mx.google.com with ESMTP id q127si14162562pfq.19.2019.02.12.05.56.59
        for <linux-mm@kvack.org>;
        Tue, 12 Feb 2019 05:57:00 -0800 (PST)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 51A144241; Tue, 12 Feb 2019 14:56:58 +0100 (CET)
Date: Tue, 12 Feb 2019 14:56:58 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Shameerali Kolothum Thodi <shameerali.kolothum.thodi@huawei.com>
Cc: Jonathan Cameron <jonathan.cameron@huawei.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"mhocko@suse.com" <mhocko@suse.com>,
	"dan.j.williams@intel.com" <dan.j.williams@intel.com>,
	"Pavel.Tatashin@microsoft.com" <Pavel.Tatashin@microsoft.com>,
	"david@redhat.com" <david@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"dave.hansen@intel.com" <dave.hansen@intel.com>,
	Linuxarm <linuxarm@huawei.com>, Robin Murphy <robin.murphy@arm.com>
Subject: Re: [RFC PATCH v2 0/4] mm, memory_hotplug: allocate memmap from
 hotadded memory
Message-ID: <20190212135658.fd3rdil634ztpekj@d104.suse.de>
References: <20190122103708.11043-1-osalvador@suse.de>
 <20190212124707.000028ea@huawei.com>
 <5FC3163CFD30C246ABAA99954A238FA8392B5DB6@lhreml524-mbs.china.huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5FC3163CFD30C246ABAA99954A238FA8392B5DB6@lhreml524-mbs.china.huawei.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 01:21:38PM +0000, Shameerali Kolothum Thodi wrote:
> > Hi Oscar,
> > 
> > I ran tests on one of our arm64 machines. Particular machine doesn't actually
> > have
> > the mechanics for hotplug, so was all 'faked', but software wise it's all the
> > same.
> > 
> > Upshot, seems to work as expected on arm64 as well.
> > Tested-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>

Thanks Jonathan for having given it a spin, much appreciated!
I was short of arm64 machines.

> (qemu) object_add memory-backend-ram,id=mem1,size=1G
> (qemu) device_add pc-dimm,id=dimm1,memdev=mem1,node=1
> root@ubuntu:~# 
> root@ubuntu:~# numactl -H
...
> node 1 cpus:
> node 1 size: 1008 MB
> node 1 free: 1008 MB
> node distances:
> node   0   1 
>   0:  10  20 
>   1:  20  10 
> root@ubuntu:~#  

Ok, this is what I wanted to see.
When you hotplugged 1GB, 16MB out of 1024MB  were spent
for the memmap array, that is why you only see 1008MB there.

I am not sure what is the default section size for arm64, but assuming
is 128MB, that would make sense as 1GB would mean 8 sections,
and each section takes 2MB.

That means that at least the mechanism works.

> 
> FWIW,
> Tested-by: Shameer Kolothum <shameerali.kolothum.thodi@huawei.com>

thanks for having tested it ;-)!
-- 
Oscar Salvador
SUSE L3


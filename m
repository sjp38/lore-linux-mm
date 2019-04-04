Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D3ADC10F0C
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 18:01:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15C6A206C0
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 18:01:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15C6A206C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A7F1A6B000E; Thu,  4 Apr 2019 14:01:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A2FAD6B0266; Thu,  4 Apr 2019 14:01:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 91E246B0269; Thu,  4 Apr 2019 14:01:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 44CCE6B000E
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 14:01:51 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id m31so1897153edm.4
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 11:01:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ogq4bdHpyNMHu4d8hlsmn/rXNhvZjZSCj04Z5dl9Nkw=;
        b=DVHIjJK3oiz+u1dXcgBvmlGEPQLldK81P4LWcWl0rhOLpAtY0N4sJKGvXHoYp15bP3
         IvfX4wkfpWa7Uc78J9X/rZi/kLBqNPaI5ig9BqU9zv87Mch488Ob341aUyhgmUaKCKtC
         XEwkNW8rs9bpnCSe/9V3+6bW1M3QHGXvoTAklRt3UIwrOCJ/EcRsqadGEYxNXQIiK9mT
         Ro3jg+wLw4ekE6UYV92EAMx/1Rj0paTi5uI1T1M+8il93M1o5DXEEtd+y2PvUWH9pbUO
         G1XnbP+sYQ3ep8xUdOZ9wlu2+ln+hciA5v7E8mH8ltCD0bzAVtLhuKz2nIgPozuQ0lL6
         1BLg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXIg//TQ1TmOx94EvBcS17cbQfURcINYlF3VYix9TxYetIkxkxS
	zrvM8J0Hk640zVIB1nCXq47wsjyaYSZWWWXzOuzKNbuTqsDmz+r7phjrZNIAmaTEh6xehg+hbrm
	+Wm5B9NOXC9VlYGtSRwOmTD27XbcqbWxlReQbakXToF7H1it6XxS4D535+nk3+wI=
X-Received: by 2002:a50:91ac:: with SMTP id g41mr4806562eda.188.1554400910834;
        Thu, 04 Apr 2019 11:01:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxaAV0rx0GO+l1VvRaQLN2Q0cHJWMRwq/mTq/B56htLyC+IVQgJZE35Dzuyluv6Gbu0y3hJ
X-Received: by 2002:a50:91ac:: with SMTP id g41mr4806465eda.188.1554400909265;
        Thu, 04 Apr 2019 11:01:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554400909; cv=none;
        d=google.com; s=arc-20160816;
        b=UMMWEh6KYnINrZZqGq4tcDUqWgKAxHTPEJkRn34c98kYzFQkpb0apxGrxD3YdEIup6
         H7CWhe4FA6sEI94bXtEwH2i/Bn4HSkaM+NOoWFiTxMmhuKnaEZDoh68SzhYKYEuMDj3u
         ooXntMKbU/eAfrordA/wGSXZuHAZCPrHsxkEVjp6nIZRFomLRY9SNncP+sk7ccrB1bbJ
         SPoJu5LoS2/zGbEBGVQkGXUev3DuVcCVUYXGhaWeOYZrBY/ayBxljFXD9lg6lbM36hy/
         nys7AKlQTjH5FXrJilF363VB/HSyJu0ySjtg1iFpApaNSKlsZW8spFAV39ImcnV5oil1
         DgnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ogq4bdHpyNMHu4d8hlsmn/rXNhvZjZSCj04Z5dl9Nkw=;
        b=FJ3iLiJwnm6xCEN1yzIiWCTSIjlQlyG9lQZwxKNQl0Y3k7ash7WfjBTeed7JYeMWsu
         BDn8AR3LvJ8idXbKEmn+k+b+u2GYaaKSDvDaCNPRRDvrT7oemPaYpzRnvgssIXP/Ffnw
         VBDi4jsAPZUymJieHoxR9fMh9c2iuPwIZPyThEVGoTRSvrQrYPpOsNRsZ1n+6N/NQp+W
         7f7FKpkMB46LuIGZ+4O8ZeZlVOyNcE6LSWoMVwcJ/IjOqB0sasHPCFB9yMLAazc+EzJK
         XvmXVG+NeMmsLC7cIEc0eHjuHWs0lWlQXH1+8EwePuhnVuwbwdsmO2NnI5hOgVvic2bY
         fWaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id y40si3874345edc.230.2019.04.04.11.01.48
        for <linux-mm@kvack.org>;
        Thu, 04 Apr 2019 11:01:49 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) client-ip=2620:113:80c0:5::2222;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id E817F4828; Thu,  4 Apr 2019 20:01:47 +0200 (CEST)
Date: Thu, 4 Apr 2019 20:01:47 +0200
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 2/2] mm, memory_hotplug: provide a more generic
 restrictions for memory hotplug
Message-ID: <20190404180144.lgpf6qgnp67ib5s7@d104.suse.de>
References: <20190404125916.10215-1-osalvador@suse.de>
 <20190404125916.10215-3-osalvador@suse.de>
 <880c5d09-7d4e-2a97-e826-a8a6572216b2@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <880c5d09-7d4e-2a97-e826-a8a6572216b2@redhat.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 04, 2019 at 04:57:03PM +0200, David Hildenbrand wrote:

> >  #ifdef CONFIG_MEMORY_HOTPLUG
> > -int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
> > -		    bool want_memblock)
> > +int arch_add_memory(int nid, u64 start, u64 size,
> > +			struct mhp_restrictions *restrictions)
> 
> Should the restrictions be marked const?

We could, but maybe some platforms want to override something later on
depending on x or y configurations, so we could be more flexible here.

> > +/*
> > + * Do we want sysfs memblock files created. This will allow userspace to online
> > + * and offline memory explicitly. Lack of this bit means that the caller has to
> > + * call move_pfn_range_to_zone to finish the initialization.
> > + */
> 
> I think you can be more precise here.
> 
> "Create memory block devices for added pages. This is usually the case
> for all system ram (and only system ram), as only this way memory can be
> onlined/offlined by user space and kdump to correctly detect the new
> memory using udev events."
> 
> Maybe we should even go a step further and call this
> 
> MHP_SYSTEM_RAM
> 
> Because that is what it is right now.

I agree that that is nicer explanation, and I would not mind to add it.
In the end, the more information and commented code the better.

But I am not really convinced by MHP_SYSTEM_RAM name, and I think we should stick
with MHP_MEMBLOCK_API because it represents __what__ is that flag about and its
function, e.g: create memory block devices.

> > @@ -1102,6 +1102,7 @@ int __ref add_memory_resource(int nid, struct resource *res)
> >  	u64 start, size;
> >  	bool new_node = false;
> >  	int ret;
> > +	struct mhp_restrictions restrictions = {};
> 
> I'd make this the very first variable.
> 
> Also eventually
> 
> struct mhp_restrictions restrictions = {
> 	.restrictions = MHP_MEMBLOCK_API
> };

It might be more right.
Actually, that is the way we tend to pre-initialize fields in structs.

About the identation, I  am really puzzled, I checked my branch and I
cannot see any space that should be a tab.
Maybe it got screwed up when sending it.

Anyway, thanks for the feedback David ;-)

-- 
Oscar Salvador
SUSE L3


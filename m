Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B26FEC4360F
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 12:02:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C46521B18
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 12:02:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C46521B18
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0CDBA6B0003; Fri, 22 Mar 2019 08:02:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 051FD6B0005; Fri, 22 Mar 2019 08:02:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E5EA56B0006; Fri, 22 Mar 2019 08:02:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 946CE6B0003
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 08:02:23 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x29so848114edb.17
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 05:02:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=lIQpyYyIOVSAqJl++3meeft3S4WTNzE4O0rGeH1/48M=;
        b=XomL/4uUti3vmsDA7h0AkyttZF3tcnXxNT5yTLnp2rBYANOnvzoHyMm9k7Yfgpldyz
         Z9ofX3uu1FqaTPaYvYJSY9g0BLe3v8Pxedd2eoJvtqZZ2ngQDLSFq4Q5rL1Brl2oGZh8
         LIGb5MUyfpxr3TTUkgKysrLfr5XU5j/ZdjlkCPcrFQYq80y6ueu8dVVTtBDocF7bzsb5
         b7TaxzvHBojC7xpkcmRrbUo+iFN6zWr4lu37/Hvb5muriE6a1YRdlRmWN8EtELNBDHpW
         owKjGU+0e5rnZf6v30L1O3T1q7ok3Nsog1SkIKJcvYi+r14paRpg2NIy6AQUgjX+VbBD
         v95Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVolqMMhRkeoqrxUHAKVxm5JsmXxZYmoW+dNvx/tCzAb1eQX66W
	QYjanHwKEp+HKHihk2r6M71h9RBk2y3Jo3QT+EHnnby6PREY6n4HrHXudM+co8Q35s1jQhuGquW
	srWgAMic8FlcWaVlf+tfrbZP+qVI4d/y5Rqsq46Nz99iB3VzyI2rXKRqSM94r444=
X-Received: by 2002:a50:86ad:: with SMTP id r42mr6343757eda.40.1553256143176;
        Fri, 22 Mar 2019 05:02:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5gCS74o/qaph5u4BbeF7Vc4S2Bc3XstLSr8aBZqSgOUwIJw6Gk8NHrMLXKJCCKRms0VtQ
X-Received: by 2002:a50:86ad:: with SMTP id r42mr6343708eda.40.1553256142313;
        Fri, 22 Mar 2019 05:02:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553256142; cv=none;
        d=google.com; s=arc-20160816;
        b=XuYoyUambBRt9D0C/b8d/rsQ/OSsgsq8rKeMyODOaALEiHfPoOOT+n3c7habc9p/Fu
         BYHv2LRyyt18nFD70ahSK096JaK3sG9Vr8MFEEsSR9IsaHyKOPIjyqtHjtK0vvCyhXNs
         wEY5tXQGcBsGteTWJC1Wa/zu2Uv36bOEt4WXzwtHXxOTHFMq4dbmf+jteGZMKYEB8+5h
         7vSlC7Wrn89Xqm/3BMxRCC8jkB97YpBsIWXU3rXe5tLqhgo9FtCbHbRwyRMGECD8w/PI
         aFAXoi1PHTFCjI0WQTZE9qEalANAY2Jq15rJn75ZBO0sqoYFucrl/DA1R6FOEXJc5IOG
         IMMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=lIQpyYyIOVSAqJl++3meeft3S4WTNzE4O0rGeH1/48M=;
        b=Ih7qV4liGoDVBM+nIX4TWiueuE6k5OoBzO4lDp+eBVn7tgj3DrV0wAxrvcKMqETiMl
         KYbTUZsfVPd984EY+YlCuyPPXFZXGBOXUadpW84AvG+6bBUYRzzDYWWfyIlhJ2e3tU7d
         8OxmMll+2wdvP3B5ygHTTuojxSwpM4T6y95kylMoyJjcjtYu3yv8lpHKGFD/AkRHjy+x
         RCKDHXJjCfgHPJ2+iLE+3sm7jovcdc78J5OEtpIZh3QSbopkUMoT3XySDDKxNgk/OuRS
         Abg4NOgB2LIXzV5J86bEbBn2XsskHvqnJ2cnyGxazimXNNFc+caIAfv5uDTp0mPwMj5H
         ghUA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gr15si1704747ejb.302.2019.03.22.05.02.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 05:02:22 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 37D71AF49;
	Fri, 22 Mar 2019 12:02:21 +0000 (UTC)
Date: Fri, 22 Mar 2019 13:02:19 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, logang@deltatee.com,
	osalvador@suse.de, hannes@cmpxchg.org, akpm@linux-foundation.org,
	richard.weiyang@gmail.com, rientjes@google.com,
	zi.yan@cs.rutgers.edu
Subject: Re: [RFC] mm/hotplug: Make get_nid_for_pfn() work with
 HAVE_ARCH_PFN_VALID
Message-ID: <20190322120219.GI32418@dhcp22.suse.cz>
References: <1553155700-3414-1-git-send-email-anshuman.khandual@arm.com>
 <20190321083639.GJ8696@dhcp22.suse.cz>
 <621cc94c-210d-6fd4-a2e1-b7cfce733cf3@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <621cc94c-210d-6fd4-a2e1-b7cfce733cf3@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 22-03-19 11:49:30, Anshuman Khandual wrote:
> 
> 
> On 03/21/2019 02:06 PM, Michal Hocko wrote:
> > On Thu 21-03-19 13:38:20, Anshuman Khandual wrote:
> >> Memory hot remove uses get_nid_for_pfn() while tearing down linked sysfs
> >> entries between memory block and node. It first checks pfn validity with
> >> pfn_valid_within() before fetching nid. With CONFIG_HOLES_IN_ZONE config
> >> (arm64 has this enabled) pfn_valid_within() calls pfn_valid().
> >>
> >> pfn_valid() is an arch implementation on arm64 (CONFIG_HAVE_ARCH_PFN_VALID)
> >> which scans all mapped memblock regions with memblock_is_map_memory(). This
> >> creates a problem in memory hot remove path which has already removed given
> >> memory range from memory block with memblock_[remove|free] before arriving
> >> at unregister_mem_sect_under_nodes().
> > 
> > Could you be more specific on what is the actual problem please? It
> > would be also helpful to mention when is the memblock[remove|free]
> > called actually.
> 
> The problem is in unregister_mem_sect_under_nodes() as it skips calling into both
> instances of sysfs_remove_link() which removes node-memory block sysfs symlinks.
> The node enumeration of the memory block still remains in sysfs even if the memory
> block itself has been removed.
> 
> This happens because get_nid_for_pfn() returns -1 for a given pfn even if it has
> a valid associated struct page to fetch the node ID from.
> 
> On arm64 (with CONFIG_HOLES_IN_ZONE)
> 
> get_nid_for_pfn() -> pfn_valid_within() -> pfn_valid -> memblock_is_map_memory()
> 
> At this point memblock for the range has been removed.
> 
> __remove_memory()
> 	memblock_free()
> 	memblock_remove()	--------> memblock has already been removed
> 	arch_remove_memory()
> 		__remove_pages()
> 			__remove_section()
> 				unregister_memory_section()
>  					remove_memory_section()
> 						unregister_mem_sect_under_nodes()
> 
> There is a dependency on memblock (after it has been removed) through pfn_valid().

Can we reorganize or rework the code that the memblock is removed later?
I guess this is what Oscar was suggesting.

Or ...

> >> During runtime memory hot remove get_nid_for_pfn() needs to validate that
> >> given pfn has a struct page mapping so that it can fetch required nid. This
> >> can be achieved just by looking into it's section mapping information. This
> >> adds a new helper pfn_section_valid() for this purpose. Its same as generic
> >> pfn_valid().
> > 
> > I have to say I do not like this. Having pfn_section_valid != pfn_valid_within
> > is just confusing as hell. pfn_valid_within should return true whenever
> > a struct page exists and it is sensible (same like pfn_valid). So it
> > seems that this is something to be solved on that arch specific side of
> > pfn_valid.
> 
> At present arm64's pfn_valid() implementation validates the pfn inside sparse
> memory section mapping as well memblock. The memblock search excludes memory
> with MEMBLOCK_NOMAP attribute. But in this particular instance during hotplug
> only section mapping validation for the pfn is good enough.
> 
> IIUC the current arm64 pfn_valid() already extends the definition beyond the
> availability of a valid struct page to operate on.

is there any way to record that nomap information into the section
instead. It looks rather weird that this information is spread into two
data structures and it makes pfn_valid more expensive at the same time.
-- 
Michal Hocko
SUSE Labs


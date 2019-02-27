Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C87EEC00319
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 21:51:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6AC852183F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 21:51:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6AC852183F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D67D78E0008; Wed, 27 Feb 2019 16:51:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D24168E0001; Wed, 27 Feb 2019 16:51:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C079C8E0008; Wed, 27 Feb 2019 16:51:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 655188E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 16:51:12 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id k32so7391795edc.23
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 13:51:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=DBXe9Cx2bUTw6d9QVUQkxcAfQsxCuvQR/9Y5DDNjYUA=;
        b=KwmuiW4CVy0DUUlkcn5VSDFPmzMpEfqHgvGkFuNbz/Rcx89b7ZI1Jnp5w9NRMOdyC7
         nnL51DExF/01kxfffa1XKS/bU/lsfrEtxVzw3iyCYoDcR2B848d3/kWSHTP3k0o3HILG
         KMIm2NzM/b0mMwPv7rLZ4+XNtHdVXRPfD3pGD8OFedok1lI6KdtVZPUldR3wr7oMjI7f
         AV3IxIoWz3NjA5nDAnqKuwqdTBJ7ldFNAfPjhuDTIk3bYQ8ox7YsTs7lLgR28UuxOHMU
         g3cPDMJkQ39P7UV8+Yw37FernPDTF+00xN9Z0dP4KvhjU5uo8tuh0Zoid6TWXGIegV3S
         vXVg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: AHQUAuZDQ8GJHGbnPLyEoOZUWk+Lnz0MrlWQ6203zHI50B/V+F+BZL8u
	r8gYEM/ce5o1LWiuW22Xa7kbh2kimIhJhy5xrF1A6bNkTqbPrM3gXPAzVc+peFx5NLKvFX8oY7+
	LLuFcv9DymoK460ifvOSHKfp9IS/+h/kfG5hvI+dmYNsWqXa2r5I+mBPzRV8s8oRvXA==
X-Received: by 2002:aa7:dac5:: with SMTP id x5mr4015468eds.56.1551304271911;
        Wed, 27 Feb 2019 13:51:11 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaCp3jH5uljtQxn2Oj+Mtsuf1N8B2s/IAscrh3HOTIil7Lzg7zS2FgApgWpW2vLWRLOPXjG
X-Received: by 2002:aa7:dac5:: with SMTP id x5mr4015423eds.56.1551304270957;
        Wed, 27 Feb 2019 13:51:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551304270; cv=none;
        d=google.com; s=arc-20160816;
        b=tyWNJkeqwchfCkpywUsSxtzy1yP2j2cyJySpaTXrY41z8/kXfk6X2t4PeMsqA6xJkN
         6b30MV+wg+mF7F1S0YOsLiq63FB0uhoCeVBTJJmnLwZm+1zhSAV2pmoC0uzf9jmqs2t5
         gbNe6wtOMdWL0Nwr7Jzuwqwcp/wfDLdx8me/ZS1e5BJd4mRTcDVcY7WxE9J7Eo2Gy+/E
         jfCkiQa4uXZM9OHZWiJBBD68VS6fnBauoIJhU6rsgIA4JaOcpThWM/dhtAlHQQAK/enz
         N5GqOkKjgQtieL7ay84w/YKdBUw0OmVo1+oufvYqULmLYfIPdSudGC11GSxldEsr830l
         NQdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=DBXe9Cx2bUTw6d9QVUQkxcAfQsxCuvQR/9Y5DDNjYUA=;
        b=kfa6sh1m2NaFTzzNxQyOUtgMUC1iMHffnFtOj60wje+eLky9CS6U7tnRDPpdy1eGRi
         iyHsnAeldQUyiD84wXly/YF1G1hj96szIW3FcYQIyhBpGHzB3vAQepTff6a38GfPiZML
         aC3DNbzqR2kKzPePL/UcQybjigwlVkEf5M5TjYuJW85719YV4TEtWYEz8zDzhD9svu0Z
         MI6YfFEh25oK36FXobFzxyrM/QELzGlnFDwDsuNmhVxwpGP6LuiUiE18NoXWG5EDh+Ar
         Iu/exgMTVUnL1Z0WESpDBCDOgYmkdyp2Lwi2hkPSHclffU2mc25vqECPcbuqCz9hiAcx
         hQgA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (charybdis-ext.suse.de. [195.135.221.2])
        by mx.google.com with ESMTP id d1si3231928ejb.259.2019.02.27.13.51.10
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 13:51:10 -0800 (PST)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id E8E8843F0; Wed, 27 Feb 2019 22:51:09 +0100 (CET)
Date: Wed, 27 Feb 2019 22:51:09 +0100
From: Oscar Salvador <osalvador@suse.de>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, mhocko@suse.com, david@redhat.com,
	mike.kravetz@oracle.com
Subject: Re: [RFC PATCH] mm,memory_hotplug: Unlock 1GB-hugetlb on x86_64
Message-ID: <20190227215109.cpiaheyqs2qdbl7p@d104.suse.de>
References: <20190221094212.16906-1-osalvador@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190221094212.16906-1-osalvador@suse.de>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 10:42:12AM +0100, Oscar Salvador wrote:
> [1] https://lore.kernel.org/patchwork/patch/998796/
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>

Any further comments on this?
I do have a "concern" I would like to sort out before dropping the RFC:

It is the fact that unless we have spare gigantic pages in other notes, the
offlining operation will loop forever (until the customer cancels the operation).
While I do not really like that, I do think that memory offlining should be done
with some sanity, and the administrator should know in advance if the system is going
to be able to keep up with the memory pressure, aka: make sure we got what we need in
order to make the offlining operation to succeed.
That translates to be sure that we have spare gigantic pages and other nodes
can take them.

Given said that, another thing I thought about is that we could check if we have
spare gigantic pages at has_unmovable_pages() time.
Something like checking "h->free_huge_pages - h->resv_huge_pages > 0", and if it
turns out that we do not have gigantic pages anywhere, just return as we have
non-movable pages.

But I would rather not convulate has_unmovable_pages() with such checks and "trust"
the administrator.

> ---
>  mm/memory_hotplug.c | 7 +------
>  1 file changed, 1 insertion(+), 6 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index d5f7afda67db..04f6695b648c 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1337,8 +1337,7 @@ static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
>  		if (!PageHuge(page))
>  			continue;
>  		head = compound_head(page);
> -		if (hugepage_migration_supported(page_hstate(head)) &&
> -		    page_huge_active(head))
> +		if (page_huge_active(head))
>  			return pfn;
>  		skip = (1 << compound_order(head)) - (page - head);
>  		pfn += skip - 1;
> @@ -1378,10 +1377,6 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>  
>  		if (PageHuge(page)) {
>  			struct page *head = compound_head(page);
> -			if (compound_order(head) > PFN_SECTION_SHIFT) {
> -				ret = -EBUSY;
> -				break;
> -			}
>  			pfn = page_to_pfn(head) + (1<<compound_order(head)) - 1;
>  			isolate_huge_page(head, &source);
>  			continue;
> -- 
> 2.13.7
> 

-- 
Oscar Salvador
SUSE L3


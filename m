Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3A89C31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 07:49:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A01112084D
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 07:49:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A01112084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E1ED6B0003; Tue, 18 Jun 2019 03:49:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 244498E0002; Tue, 18 Jun 2019 03:49:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BE348E0001; Tue, 18 Jun 2019 03:49:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B00C76B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 03:49:52 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k15so20105310eda.6
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 00:49:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=O0t0yeKLQMkxo0iGtnu+8k2O33PHHYd/4K1zbHNT6sI=;
        b=L3HV1TQt/eJOit4YgmWJd18OgupU3SQuUpb2CfNysgliAH//N90ZuwGAUOi0TUhoBG
         70NlhNIMR6FMn24iqasdeF4rZCDf1IHMbicDjx/1goTsq/taV0rydhMfAHVVbJkEb0Wj
         Ru9Eb+EtIWgtq7757jBGgE//JpEWI83f6uVuB8xiRD3kqUwSrTtztmuC0jjqx2YBIfad
         p8752fi7n+UIangdC6lApoalJS1MtkCMsEcFFKNThSgobCfICjqreV7JuvkEmXgYzu0Y
         CgPDod23B2hPdnpNWzKMuKmScNZtvSWAqM2rrlceeI09yoCbZXXylkYwEyhYf7+Dn/U6
         SjkA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWRNLoXfiocRHTKUoJSSWGFqmWaqPrriDzJuXlV8zzHj68dLnsW
	dIeOb8HDjJ1n0Uw2Sp7+zwDkX+FaBspaGsKsFQviE7Iih3NHYuj6b8v0hNCzm0rdX334zpKQYFU
	NqLZwHvSJSrsoq4mebfPJrAZUgkLjsymWEpvW6eJt7+QV1V4tXXC/2uq3WLaLmeT9zQ==
X-Received: by 2002:aa7:ca45:: with SMTP id j5mr26068627edt.217.1560844192292;
        Tue, 18 Jun 2019 00:49:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHsPb6hSQ+egnMwoDzKzhBlFHedyYwGhq7Bx33Ig29KBcqVynR8K7Rs/SMCbT1mhhxcLuK
X-Received: by 2002:aa7:ca45:: with SMTP id j5mr26068561edt.217.1560844191491;
        Tue, 18 Jun 2019 00:49:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560844191; cv=none;
        d=google.com; s=arc-20160816;
        b=Dg8HzIdr/CRaCHQVkm6UGrlAqSTFHHn1i9Yr3yLxRh1k0CEr0eaLa9jFQPSLI5QK8y
         B3utcWV2VjWNjtoAGoslrgEDL/o9vVZLdkm5qZ6+qAjVdFmuyCGbIITAdIxuVS53HjP+
         SlGb6XLwsCc7EZ8ikbN2lOPR1e5JxoMEr1c5/oW5i2Oxq6hB36UShDqyPR3a0v/0no0R
         Geaz9Jx4A61n9Xq+tqyoYqFdd886v1i7uuzra4vvxpoQDJRnl1vkH8lIdVDXbuNQuV22
         n0WhjIHVQqvhUhX09EFuwNazp6Fvx18kdDTrWpKhkTf2I5gEgAR8K7tS32rHQXLsgqE8
         lxbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=O0t0yeKLQMkxo0iGtnu+8k2O33PHHYd/4K1zbHNT6sI=;
        b=QGWCA46fPeLirXILoX8UYXNr9wiFjlCd/zQ2oxdPRfCTebIw42W8O7mNgd50DNH2KY
         kSTYS+7WPQmBarZfgIsH+8ruqF0ehUsflLBYYuWOmfVLK2lL2EI1TsEqcmgb8/7b54gN
         95P8hYfolFDICKb0F9Z5mjGVx/VETrZFWORFU21+IR6B5IRMaWmjeg4XjVjWAIt5CgS2
         hCDBEauRC6oE8UN21gaVjkbgKgp/q3WabymqYzcMHE0/HhKV+Ia9qrxNYF0WIA/v0GOc
         czXBLofgaytMeazPMmxqSCZ+7h/cW2C4H88uPVF7QbzD8Z3MCNzeppeUunWVL7qdT8Dp
         EOsA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 9si9053143ejk.221.2019.06.18.00.49.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 00:49:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id CEBCEAFA9;
	Tue, 18 Jun 2019 07:49:50 +0000 (UTC)
Date: Tue, 18 Jun 2019 09:49:48 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Wei Yang <richardw.yang@linux.intel.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, david@redhat.com,
	anshuman.khandual@arm.com
Subject: Re: [PATCH v2] mm/sparse: set section nid for hot-add memory
Message-ID: <20190618074900.GA10030@linux>
References: <20190618005537.18878-1-richardw.yang@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190618005537.18878-1-richardw.yang@linux.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 18, 2019 at 08:55:37AM +0800, Wei Yang wrote:
> In case of NODE_NOT_IN_PAGE_FLAGS is set, we store section's node id in
> section_to_node_table[]. While for hot-add memory, this is missed.
> Without this information, page_to_nid() may not give the right node id.
> 
> BTW, current online_pages works because it leverages nid in memory_block.
> But the granularity of node id should be mem_section wide.

I forgot to ask this before, but why do you mention online_pages here?
IMHO, it does not add any value to the changelog, and it does not have much
to do with the matter.

online_pages() works with memblock granularity and not section granularity.
That memblock is just a hot-added range of memory, worth of either 1 section or multiple
sections, depending on the arch or on the size of the current memory.
And we assume that each hot-added memory all belongs to the same node.


> Signed-off-by: Wei Yang <richardw.yang@linux.intel.com>
> Reviewed-by: Oscar Salvador <osalvador@suse.de>
> Reviewed-by: David Hildenbrand <david@redhat.com>
> Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>
> 
> ---
> v2:
>   * specify the case NODE_NOT_IN_PAGE_FLAGS is effected.
>   * list one of the victim page_to_nid()
> 
> ---
>  mm/sparse.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 4012d7f50010..48fa16038cf5 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -733,6 +733,7 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
>  	 */
>  	page_init_poison(memmap, sizeof(struct page) * PAGES_PER_SECTION);
>  
> +	set_section_nid(section_nr, nid);
>  	section_mark_present(ms);
>  	sparse_init_one_section(ms, section_nr, memmap, usemap);
>  
> -- 
> 2.19.1
> 

-- 
Oscar Salvador
SUSE L3


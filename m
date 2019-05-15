Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB8E7C46470
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 17:34:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE2D42087E
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 17:34:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE2D42087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4FD1B6B0006; Wed, 15 May 2019 13:34:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D4DB6B0007; Wed, 15 May 2019 13:34:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C3866B0008; Wed, 15 May 2019 13:34:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 06CF26B0006
	for <linux-mm@kvack.org>; Wed, 15 May 2019 13:34:45 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id z7so374630pgc.1
        for <linux-mm@kvack.org>; Wed, 15 May 2019 10:34:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=YWa2PD6tH6ZQWGjQMACiEGWV6SmTrTUziLaTxaR+k4Q=;
        b=jt3mcQKzTFTZdDuM7eT9lAXJdR44xYZ5plIqIexSpmZMiznA9F4zkxzu+aArfNJm2e
         3FWt3LVagLYP8Ss5jHvjRV3R5MX5irSI37hvVoC1aWMne0HU0y+lJWBeslnGmDYgkEMX
         BgP0E8krxszCJNAnAhMQzbbnn3ulELeamelfkjcDpKpoLMxQQ1uPUhBZXGWjfwO64DPE
         JxvM+6fPy1kmGHI9lJ7bgGyzU9SjFobg4GTjU5PP2wH5CEA/QgQL5J/8SExJS2iF1ogQ
         26fpQafJ65CWUYqGdwdEVQSkYL4kfu1vHuc9dFG5le/0egKA3iGElaWojpdduxfE6EoY
         Uwcg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVUNQTU37vl8170FRYrX3+9bLGEF/ZMX+Osjt3dGe8r7XBgQHOI
	2znl8t4GhIUuOgWb71mAnpIDT5ufisVncGBlF5YHghfJMBoh2IYUIjeB5psgGjq5llcdHS/MXsZ
	N8fUJB4OhF6BDm0s5C2U55K0fLyKaqy8X4fqFYsBOdtKhGSgHtdiEf02jeqEdPR7OWQ==
X-Received: by 2002:a63:2b41:: with SMTP id r62mr45492628pgr.403.1557941684581;
        Wed, 15 May 2019 10:34:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz5VroThG+LQgG8x6PU5ucxRZeFAjGeYBDFK+KftWWWbD/nSYmlgfyt91bNxRUWO3REbUIm
X-Received: by 2002:a63:2b41:: with SMTP id r62mr45492560pgr.403.1557941683883;
        Wed, 15 May 2019 10:34:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557941683; cv=none;
        d=google.com; s=arc-20160816;
        b=o9fKYUz5vhKShWnl31pqNUEO/WOoL0dWCHU4L1n/eJsWNbVfsgbKQLv+PsZoyXO7eg
         FiS7FEAlxfIQkOmF6yR+8xbDY3fDlcRuncp2amOsSAcciz0JOMo8aPUiJgcD7+bvsCIW
         cT5qTH1IvXxnDPq1QaWdkwE2CkIMtdAKfP1MRCkv1CzFh4e0FDWSPlTKt+VHVU8shhKu
         lGNlOdqivO4Ph3PhwGPeX+MJ0KhFlVGM5jwhx4s0KGIiO37lySwc1IHVJgA1N2lqNDP7
         wNFNPWLUni/VF7CUWA3a2PHbSJu8R1ph1dH9XqS4qM6zaN/qHhnrSDJSQyMGZIJslwj3
         a0pQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=YWa2PD6tH6ZQWGjQMACiEGWV6SmTrTUziLaTxaR+k4Q=;
        b=yYWd0Bi9M/N6jdGZyQ5lxmKzqyf8dZhZznSiBwVnx5L3su8/NPtokd3qxKG1fPNKCM
         t0zyut0LW9370NQ6ZsZKnzoeqnunQRnrtiA1yIdaMpU6YUhH4Fidp3GD1hjaN0wC86JR
         afdTKswCoPK2NXp/thGsXRg60iB8uwNiItcBbY1/OAH89U5oTzeLnaYkwF2G5iVFWrFV
         5wXXLleLgX0hLG3Oy4iDwHQSvmW2dhUu2DFvmVwcSQty9R5HXWPF1MwqMNmyp1Gvcsvi
         /vcNsmju+SyabJyEXAN3kQ4N1w0y5vP2tbL3mSHV5ZGivsAqDU8eaQQRtPj1MTfxxMk5
         lDsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id c10si992409pll.428.2019.05.15.10.34.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 10:34:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 15 May 2019 10:34:43 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga001.fm.intel.com with ESMTP; 15 May 2019 10:34:43 -0700
Date: Wed, 15 May 2019 10:35:26 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	Johannes Weiner <hannes@cmpxchg.org>,
	Matthew Wilcox <willy@infradead.org>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH] mm: refactor __vunmap() to avoid duplicated call to
 find_vm_area()
Message-ID: <20190515173525.GB1888@iweiny-DESK2.sc.intel.com>
References: <20190514235111.2817276-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190514235111.2817276-1-guro@fb.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

>  
> -/* Handle removing and resetting vm mappings related to the vm_struct. */
> -static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
> +/* Handle removing and resetting vm mappings related to the va->vm vm_struct. */
> +static void vm_remove_mappings(struct vmap_area *va, int deallocate_pages)

Does this apply to 5.1?  I'm confused because I can't find vm_remove_mappings()
in 5.1.

Ira

>  {
> +	struct vm_struct *area = va->vm;
>  	unsigned long addr = (unsigned long)area->addr;
>  	unsigned long start = ULONG_MAX, end = 0;
>  	int flush_reset = area->flags & VM_FLUSH_RESET_PERMS;
> @@ -2138,7 +2143,7 @@ static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
>  		set_memory_rw(addr, area->nr_pages);
>  	}
>  
> -	remove_vm_area(area->addr);
> +	__remove_vm_area(va);
>  
>  	/* If this is not VM_FLUSH_RESET_PERMS memory, no need for the below. */
>  	if (!flush_reset)
> @@ -2178,6 +2183,7 @@ static void vm_remove_mappings(struct vm_struct *area, int deallocate_pages)
>  static void __vunmap(const void *addr, int deallocate_pages)
>  {
>  	struct vm_struct *area;
> +	struct vmap_area *va;
>  
>  	if (!addr)
>  		return;
> @@ -2186,17 +2192,18 @@ static void __vunmap(const void *addr, int deallocate_pages)
>  			addr))
>  		return;
>  
> -	area = find_vm_area(addr);
> -	if (unlikely(!area)) {
> +	va = find_vmap_area((unsigned long)addr);
> +	if (unlikely(!va || !(va->flags & VM_VM_AREA))) {
>  		WARN(1, KERN_ERR "Trying to vfree() nonexistent vm area (%p)\n",
>  				addr);
>  		return;
>  	}
>  
> +	area = va->vm;
>  	debug_check_no_locks_freed(area->addr, get_vm_area_size(area));
>  	debug_check_no_obj_freed(area->addr, get_vm_area_size(area));
>  
> -	vm_remove_mappings(area, deallocate_pages);
> +	vm_remove_mappings(va, deallocate_pages);
>  
>  	if (deallocate_pages) {
>  		int i;
> @@ -2212,7 +2219,6 @@ static void __vunmap(const void *addr, int deallocate_pages)
>  	}
>  
>  	kfree(area);
> -	return;
>  }
>  
>  static inline void __vfree_deferred(const void *addr)
> -- 
> 2.20.1
> 


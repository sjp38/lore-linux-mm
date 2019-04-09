Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42A7CC10F0E
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 22:41:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F09CB20820
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 22:41:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F09CB20820
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E0226B0005; Tue,  9 Apr 2019 18:41:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 88F886B0006; Tue,  9 Apr 2019 18:41:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 77F276B0008; Tue,  9 Apr 2019 18:41:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4064E6B0005
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 18:41:19 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id c64so126560pfb.6
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 15:41:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=kJR4Cs2u68Svee5sCAZUlWDJAJA0qEjqEr4ebK9+5us=;
        b=ozUwcH/Ix5NEXMzAcev5TKdSC145dUC1XCFrtVPNc3/KRZr1s3K35B4T/mq6oPvbf1
         qI1SHLtEXJStIpP8//k7mZBlnVpj56GuNwBiSdOjc5DuQYdcEYOi8pWLKFRkEdXNA2vb
         LJe2Z4kdYUe59cm5G/EzZ1TcoDufKsHkb+dBL6wnlJ5yyaGkCp9Chea5o5JEyuMnj0k3
         FbohvxyQ7n1GHiokdU9GuZUGUw2/uZrG3B8BcxgCNUnOddi1LxMcdULCVBZF21pLqj8a
         w0fu7DYsVBeiuVEwgUdoqMw2CviZkEFdpWF4PbTwwaIK5lmD4jIZEshxm3qzTVWt7QNc
         zwtw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAWMRuY/P8gi2t2BPmpsbWliy5B1ovuXguH0ovBm2wWUGKh6mthd
	4k7PK4rVWWmztJFBbZlzlo3t6azHFCimtQGGPsNcCCn1TRUeX2atGwjYDDXwfQmciFBnwRak8KO
	74PNDRDNi5s5cOFDx407uHAwYl5pXmOsbU/H6BcTxrVlmVtboqhpxq/h2z3yByCMn1A==
X-Received: by 2002:a17:902:47c2:: with SMTP id d2mr39772523plh.277.1554849678872;
        Tue, 09 Apr 2019 15:41:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxPGECOZPJb2HjgOZqie5nsoZYjm77sm+J1dGZMDr3aoaLEbwjD3O3NUy8pS/F1f8sFOgHy
X-Received: by 2002:a17:902:47c2:: with SMTP id d2mr39772460plh.277.1554849677834;
        Tue, 09 Apr 2019 15:41:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554849677; cv=none;
        d=google.com; s=arc-20160816;
        b=B+5+gsZRY9chXmNzLJfAGBTxMxUultl08jexWGcjCvW3O625VGG21Dqb0/nMuDNzCN
         9q2CeHNpzLKMhsJrz8FrQ9mi+p+Nl3RQWE95UNsqvVf7QFneGKqHZeKXFOe/CDeXwtuY
         9LAIDPlENt7pM3nNlx3q9iZP1qGpFJqbHJctpTihk6wXE3xX0q6KcKsIKs+dHIQFQNb/
         UKhti04rVkLjRFN/+iEzNjQ++CMezM2xzzll04bkhN2pWFRskQya1bgsP7ArJHsvYPcS
         IZ5WVTeAGf8smCEDdeI5+/bTP+Aq8MqoaLH2w9SOFXjgXZHOJ5qyKPJ6PanjDWvDGwjV
         0SZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=kJR4Cs2u68Svee5sCAZUlWDJAJA0qEjqEr4ebK9+5us=;
        b=TLHj/xhHp9paF374P75vecb69gOh+73bXORjTFwYhKGBePDbHu0o02i7oYbUB6UKMH
         Kq18Zmi1i6onYWBWGI0GYBOFX7DkxZDv+oaJwkqWJvtZpLUsa0oF7pcOxTF3i8Lf0fX7
         Nl/r5nFYtk5Tl2Yj2E8WcKyyFihdknskMyge9n1zys3blkhd0DRrama4AG90UzGB/p/M
         6GgSz8VisH4NC4UejWMxZn8wXDQK2tl0f3o4Cx0hG9+/hCpfDfncQeog2Rkcm+9pP5Be
         9soHL05wiQqFw4Nm/xe94Y2l8xFn0fjdK0f+PWzHvE/yYGwfTCEkhWDRgB8xIyJt8Ctc
         dFng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t10si29890915plr.229.2019.04.09.15.41.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 15:41:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id D3AE610D5;
	Tue,  9 Apr 2019 22:41:16 +0000 (UTC)
Date: Tue, 9 Apr 2019 15:41:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador
 <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>, Pavel Tatashin
 <pasha.tatashin@soleen.com>, Wei Yang <richard.weiyang@gmail.com>, Qian Cai
 <cai@lca.pw>, Arun KS <arunks@codeaurora.org>, Mathieu Malaterre
 <malat@debian.org>
Subject: Re: [PATCH v1 1/4] mm/memory_hotplug: Release memory resource after
 arch_remove_memory()
Message-Id: <20190409154115.0e94499072e93947a9c1e54e@linux-foundation.org>
In-Reply-To: <20190409100148.24703-2-david@redhat.com>
References: <20190409100148.24703-1-david@redhat.com>
	<20190409100148.24703-2-david@redhat.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue,  9 Apr 2019 12:01:45 +0200 David Hildenbrand <david@redhat.com> wrote:

> __add_pages() doesn't add the memory resource, so __remove_pages()
> shouldn't remove it. Let's factor it out. Especially as it is a special
> case for memory used as system memory, added via add_memory() and
> friends.
> 
> We now remove the resource after removing the sections instead of doing
> it the other way around. I don't think this change is problematic.
> 
> add_memory()
> 	register memory resource
> 	arch_add_memory()
> 
> remove_memory
> 	arch_remove_memory()
> 	release memory resource
> 
> While at it, explain why we ignore errors and that it only happeny if
> we remove memory in a different granularity as we added it.

Seems sane.

> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1820,6 +1806,25 @@ void try_offline_node(int nid)
>  }
>  EXPORT_SYMBOL(try_offline_node);
>  
> +static void __release_memory_resource(u64 start, u64 size)
> +{
> +	int ret;
> +
> +	/*
> +	 * When removing memory in the same granularity as it was added,
> +	 * this function never fails. It might only fail if resources
> +	 * have to be adjusted or split. We'll ignore the error, as
> +	 * removing of memory cannot fail.
> +	 */
> +	ret = release_mem_region_adjustable(&iomem_resource, start, size);
> +	if (ret) {
> +		resource_size_t endres = start + size - 1;
> +
> +		pr_warn("Unable to release resource <%pa-%pa> (%d)\n",
> +			&start, &endres, ret);
> +	}
> +}

The types seem confused here.  Should `start' and `size' be
resource_size_t?  Or maybe phys_addr_t.

release_mem_region_adjustable() takes resource_size_t's.

Is %pa the way to print a resource_size_t?  I guess it happens to work
because resource_size_t happens to map onto phys_addr_t, which isn't
ideal.

Wanna have a headscratch over that?

>  /**
>   * remove_memory
>   * @nid: the node ID
> @@ -1854,6 +1859,7 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
>  	memblock_remove(start, size);
>  
>  	arch_remove_memory(nid, start, size, NULL);
> +	__release_memory_resource(start, size);
>  
>  	try_offline_node(nid);


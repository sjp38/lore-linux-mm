Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 493E66B52E0
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 15:07:14 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id l65-v6so5468167pge.17
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 12:07:14 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id c12-v6si2473142plz.456.2018.08.30.12.07.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 12:07:12 -0700 (PDT)
Subject: Re: [PATCH V4 4/4] kvm: add a check if pfn is from NVDIMM pmem.
References: <cover.1534934405.git.yi.z.zhang@linux.intel.com>
 <a4183c0f0adfb6d123599dd306062fd193e83f5a.1534934405.git.yi.z.zhang@linux.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <4192066a-79f3-2b3e-386f-c4ec9b6dd8fd@intel.com>
Date: Thu, 30 Aug 2018 12:07:11 -0700
MIME-Version: 1.0
In-Reply-To: <a4183c0f0adfb6d123599dd306062fd193e83f5a.1534934405.git.yi.z.zhang@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yi <yi.z.zhang@linux.intel.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, pbonzini@redhat.com, dan.j.williams@intel.com, dave.jiang@intel.com, yu.c.zhang@intel.com, pagupta@redhat.com, david@redhat.com, jack@suse.cz, hch@lst.de
Cc: linux-mm@kvack.org, rkrcmar@redhat.com, jglisse@redhat.com, yi.z.zhang@intel.com

On 08/22/2018 03:58 AM, Zhang Yi wrote:
>  bool kvm_is_reserved_pfn(kvm_pfn_t pfn)
>  {
> -	if (pfn_valid(pfn))
> -		return PageReserved(pfn_to_page(pfn));
> +	struct page *page;
> +
> +	if (pfn_valid(pfn)) {
> +		page = pfn_to_page(pfn);
> +		return PageReserved(page) && !is_dax_page(page);
> +	}

This is in desperate need of commenting about what it is doing and why.

The changelog alone doesn't cut it.

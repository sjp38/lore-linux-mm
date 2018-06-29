Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id B92296B000A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 13:16:59 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id p91-v6so5308203plb.12
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 10:16:59 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 6-v6si8849648pgg.366.2018.06.29.10.16.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 10:16:58 -0700 (PDT)
Subject: Re: [PATCH v5 4/4] mm/sparse: Optimize memmap allocation during
 sparse_init()
References: <20180627013116.12411-1-bhe@redhat.com>
 <20180627013116.12411-5-bhe@redhat.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <cb67381c-078c-62e6-e4c0-9ecf3de9e84d@intel.com>
Date: Fri, 29 Jun 2018 10:16:56 -0700
MIME-Version: 1.0
In-Reply-To: <20180627013116.12411-5-bhe@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, pagupta@redhat.com
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com

> +	/* The numner of present sections stored in nr_present_sections

		^ "number", please.

This comment needs CodingStyle love.

> +	 * are kept the same since mem sections are marked as present in
	
	   ^ s/are/is/

This sentence is really odd to me.  What is the point?  Just that we are
not making sections present?  Could we just say that instead of
referring to functions and variable names?

> +	 * memory_present(). In this for loop, we need check which sections
> +	 * failed to allocate memmap or usemap, then clear its
> +	 * ->section_mem_map accordingly.

Rather than referring to the for loop, how about we actually comment the
code that is doing this operation?

>  					   During this process, we need

This is missing a "to": "we need _to_ increase".

> +	 * increase 'nr_consumed_maps' whether its allocation of memmap
> +	 * or usemap failed or not, so that after we handle the i-th
> +	 * memory section, can get memmap and usemap of (i+1)-th section
> +	 * correctly. */

This makes no sense to me.  Why are we incrementing 'nr_consumed_maps'
when we do not consume one?

You say that we increment it so that things will work, but not how or
why it makes things work.  I'm confused.

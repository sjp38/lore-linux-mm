Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5026E6B6DEC
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 04:14:46 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id c73so11930203itd.1
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 01:14:46 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id h13si6206788ith.85.2018.12.04.01.14.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Dec 2018 01:14:42 -0800 (PST)
Date: Tue, 4 Dec 2018 10:14:34 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC v2 04/13] x86/mm: Add helper functions for MKTME memory
 encryption keys
Message-ID: <20181204091434.GQ11614@hirez.programming.kicks-ass.net>
References: <cover.1543903910.git.alison.schofield@intel.com>
 <bd83f72d30ccfc7c1bc7ce9ab81bdf66e78a1d7d.1543903910.git.alison.schofield@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bd83f72d30ccfc7c1bc7ce9ab81bdf66e78a1d7d.1543903910.git.alison.schofield@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alison Schofield <alison.schofield@intel.com>
Cc: dhowells@redhat.com, tglx@linutronix.de, jmorris@namei.org, mingo@redhat.com, hpa@zytor.com, bp@alien8.de, luto@kernel.org, kirill.shutemov@linux.intel.com, dave.hansen@intel.com, kai.huang@intel.com, jun.nakajima@intel.com, dan.j.williams@intel.com, jarkko.sakkinen@intel.com, keyrings@vger.kernel.org, linux-security-module@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

On Mon, Dec 03, 2018 at 11:39:51PM -0800, Alison Schofield wrote:
> +int mktme_map_keyid_from_key(void *key)
> +{
> +	int i;
> +
> +	for (i = 1; i <= mktme_nr_keyids; i++)
> +		if (mktme_map->key[i] == key)
> +			return i;

CodingStyle

> +	return 0;
> +}
> +int mktme_map_get_free_keyid(void)
> +{
> +	int i;
> +
> +	if (mktme_map->mapped_keyids < mktme_nr_keyids) {
> +		for (i = 1; i <= mktme_nr_keyids; i++)
> +			if (mktme_map->key[i] == 0)
> +				return i;

CodingStyle

> +	}
> +	return 0;
> +}

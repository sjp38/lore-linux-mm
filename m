Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 95E5E6B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 11:54:57 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g78so3625660pfg.4
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 08:54:57 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id s88si233089pfg.292.2017.06.14.08.54.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 08:54:56 -0700 (PDT)
Subject: Re: [PATCH v2 03/10] x86/mm: Give each mm TLB flush generation a
 unique ID
References: <cover.1497415951.git.luto@kernel.org>
 <65ee83f8ef7259053e117355b0597b03ce096e07.1497415951.git.luto@kernel.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <06ea73a2-f724-5b3e-5d9d-143d91ba94ae@intel.com>
Date: Wed, 14 Jun 2017 08:54:55 -0700
MIME-Version: 1.0
In-Reply-To: <65ee83f8ef7259053e117355b0597b03ce096e07.1497415951.git.luto@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, x86@kernel.org
Cc: linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On 06/13/2017 09:56 PM, Andy Lutomirski wrote:
>  typedef struct {
> +	/*
> +	 * ctx_id uniquely identifies this mm_struct.  A ctx_id will never
> +	 * be reused, and zero is not a valid ctx_id.
> +	 */
> +	u64 ctx_id;

Ahh, and you need this because an mm itself might get reused by being
freed and reallocated?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

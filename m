Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id ACF8B6B0037
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 18:23:55 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id rr13so2257207pbb.32
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 15:23:55 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id cw3si7106866pbc.117.2014.06.25.15.23.54
        for <linux-mm@kvack.org>;
        Wed, 25 Jun 2014 15:23:54 -0700 (PDT)
Message-ID: <53AB4BF1.3000504@intel.com>
Date: Wed, 25 Jun 2014 15:23:45 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm: catch memory commitment underflow
References: <20140624201606.18273.44270.stgit@zurg> <20140624201614.18273.39034.stgit@zurg>
In-Reply-To: <20140624201614.18273.39034.stgit@zurg>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org

On 06/24/2014 01:16 PM, Konstantin Khlebnikov wrote:
> reserve;
>  
> +#ifdef CONFIG_DEBUG_VM
> +	WARN_ONCE(percpu_counter_read(&vm_committed_as) <
> +			-(s64)vm_committed_as_batch * num_online_cpus(),
> +			"memory commitment underflow");
> +#endif

Why not use VM_WARN_ON_ONCE()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

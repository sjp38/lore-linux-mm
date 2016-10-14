Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6999C6B0038
	for <linux-mm@kvack.org>; Fri, 14 Oct 2016 15:17:03 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id os4so121639812pac.5
        for <linux-mm@kvack.org>; Fri, 14 Oct 2016 12:17:03 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id j67si19585162pfe.197.2016.10.14.12.17.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 14 Oct 2016 12:17:02 -0700 (PDT)
Subject: Re: pkeys: Remove easily triggered WARN
References: <20161014182624.4yzw36n4hd7x56wi@codemonkey.org.uk>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <58012F29.8040307@intel.com>
Date: Fri, 14 Oct 2016 12:16:57 -0700
MIME-Version: 1.0
In-Reply-To: <20161014182624.4yzw36n4hd7x56wi@codemonkey.org.uk>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@codemonkey.org.uk>
Cc: linux-arch@vger.kernel.org, mgorman@techsingularity.net, arnd@arndb.de, linux-api@vger.kernel.org, linux-mm@kvack.org, luto@kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org

On 10/14/2016 11:26 AM, Dave Jones wrote:
> This easy-to-trigger warning shows up instantly when running
> Trinity on a kernel with CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS disabled.
> 
> At most this should have been a printk, but the -EINVAL alone should be more
> than adequate indicator that something isn't available.

Urg, thanks for the patch.  It's obviously correct, of course.

Acked-by: Dave Hansen <dave.hansen@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

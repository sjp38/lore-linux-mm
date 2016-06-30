Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6E92D6B0005
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 05:41:29 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id f126so72953252wma.3
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 02:41:29 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id gx10si3325995wjb.180.2016.06.30.02.41.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jun 2016 02:41:28 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id 187so21288678wmz.1
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 02:41:28 -0700 (PDT)
Date: Thu, 30 Jun 2016 11:41:23 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/9] [v3] System Calls for Memory Protection Keys
Message-ID: <20160630094123.GA29268@gmail.com>
References: <20160609000117.71AC7623@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160609000117.71AC7623@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, arnd@arndb.de, Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>


* Dave Hansen <dave@sr71.net> wrote:

> Are there any concerns with merging these into the x86 tree so
> that they go upstream for 4.8?  The updates here are pretty
> minor.

>  include/linux/pkeys.h                         |   39 +-
>  include/uapi/asm-generic/mman-common.h        |    5 +
>  include/uapi/asm-generic/unistd.h             |   12 +-
>  mm/mprotect.c                                 |  134 +-

So I'd love to have some high level MM review & ack for these syscall ABI 
extensions.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

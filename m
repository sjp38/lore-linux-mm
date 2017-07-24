Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E86B46B0311
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 09:59:53 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id v190so146790805pgv.12
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 06:59:53 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a13si2233192pli.236.2017.07.24.06.59.52
        for <linux-mm@kvack.org>;
        Mon, 24 Jul 2017 06:59:52 -0700 (PDT)
Date: Mon, 24 Jul 2017 14:59:47 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v2] kmemleak: add oom=<disable|ignore> runtime parameter
Message-ID: <20170724135946.srzjfrjfnv6oldjc@armageddon.cambridge.arm.com>
References: <1500887794-3262-1-git-send-email-shuwang@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1500887794-3262-1-git-send-email-shuwang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: shuwang@redhat.com
Cc: corbet@lwn.net, akpm@linux-foundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jul 24, 2017 at 05:16:34PM +0800, shuwang@redhat.com wrote:
> When running memory stress tests, kmemleak could be easily disabled in
> function create_object as system is out of memory and kmemleak failed to
> alloc from object_cache. Since there's no way to enable kmemleak after
> it's off, simply ignore the object_cache alloc failure will just loses
> track of some memory objects, but could increase the usability of kmemleak
> under memory stress.

I wonder how usable kmemleak is when not recording all the allocated
objects. If some of these memory blocks contain references to others,
such referenced objects could be reported as leaks (basically increasing
the false positives rate).

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

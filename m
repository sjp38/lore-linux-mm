Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f51.google.com (mail-lf0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0317C6B0288
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 11:31:48 -0400 (EDT)
Received: by mail-lf0-f51.google.com with SMTP id g184so101779029lfb.3
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 08:31:47 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j3si31802086wjb.167.2016.04.04.08.31.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Apr 2016 08:31:46 -0700 (PDT)
Subject: Re: /proc/meminfo question
References: <1459754566.19748.9.camel@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <570288E1.4060203@suse.cz>
Date: Mon, 4 Apr 2016 17:31:45 +0200
MIME-Version: 1.0
In-Reply-To: <1459754566.19748.9.camel@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lin <mlin@kernel.org>, linux-mm@kvack.org
Cc: fengguang.wu@intel.com

On 04/04/2016 09:22 AM, Ming Lin wrote:
> Hi,
>
> I'm debugging a memory leak in an internal driver.
> There is ~2G leak after stress tests.
>
> If I read below /proc/meminfo correctly, it doesn't show where the 2G
> memory is possibly used.
>
> Buffers + Cached + Active*/Inactive* + Slab* only about 300M.
>
> Is there other statistics not shown in /proc/meminfo or am I missing
> obvious things?

Nope. Statistics exist only for the common cases. Having e.g. each 
driver add own line there wouldn't be feasible.

However I already considered and would welcome an explicit 
"Unaccounted:" line in /prec/meminfo, so that the amount of possibly 
leaked memory is immediately visible and one doesn't need to remember 
which lines are best to sum up and whether there were subtle changes 
depending on kernel version.

> root@target:~# page-types
>               flags	page-count       MB  symbolic-flags			long-symbolic-flags

For debugging such leaks I suggest you try the page_owner functionality 
instead.

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

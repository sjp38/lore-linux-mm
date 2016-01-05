Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2A5406B0005
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 05:51:44 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id b14so22774871wmb.1
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 02:51:44 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gl5si61909156wjd.197.2016.01.05.02.51.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Jan 2016 02:51:42 -0800 (PST)
Subject: Re: [PATCH 01/32] mm, gup: introduce concept of "foreign"
 get_user_pages()
References: <20151214190542.39C4886D@viggo.jf.intel.com>
 <20151214190544.74DCE448@viggo.jf.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <568BA039.4060901@suse.cz>
Date: Tue, 5 Jan 2016 11:51:37 +0100
MIME-Version: 1.0
In-Reply-To: <20151214190544.74DCE448@viggo.jf.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, n-horiguchi@ah.jp.nec.com

On 12/14/2015 08:05 PM, Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
>
> For protection keys, we need to understand whether protections
> should be enforced in software or not.  In general, we enforce
> protections when working on our own task, but not when on others.
> We call these "current" and "foreign" operations.
>
> This introduces two new get_user_pages() variants:
>
> 	get_current_user_pages()
> 	get_foreign_user_pages()
>
> get_current_user_pages() is a drop-in replacement for when
> get_user_pages() was called with (current, current->mm, ...) as
> arguments.  Using it makes a few of the call sites look a bit
> nicer.
>
> get_foreign_user_pages() is a replacement for when
> get_user_pages() is called on non-current tsk/mm.
>
> We leave a stub get_user_pages() around with a __deprecated
> warning.

Changelog doesn't mention that get_user_pages_unlocked() is also changed 
to be effectively get_current_user_pages_unlocked(). It's a bit 
non-obvious and the inconsistent naming is unfortunate, but I can see 
how get_current_user_pages_unlocked() would be too long, and just 
deleting the parameters from get_user_pages() would be too large and 
intrusive. But please mention this in changelog?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

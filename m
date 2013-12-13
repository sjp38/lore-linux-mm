Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f172.google.com (mail-ea0-f172.google.com [209.85.215.172])
	by kanga.kvack.org (Postfix) with ESMTP id D6D076B006E
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 03:14:59 -0500 (EST)
Received: by mail-ea0-f172.google.com with SMTP id q10so598236ead.3
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 00:14:59 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l2si1004046een.209.2013.12.13.00.14.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 13 Dec 2013 00:14:58 -0800 (PST)
Message-ID: <52AAC1FE.1010409@suse.cz>
Date: Fri, 13 Dec 2013 09:14:54 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: documentation: remove hopelessly out-of-date locking
 doc
References: <1386703084-24118-1-git-send-email-dave.hansen@intel.com>
In-Reply-To: <1386703084-24118-1-git-send-email-dave.hansen@intel.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, akpm@linux-foundation.org
Cc: hughd@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/10/2013 08:18 PM, Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@intel.com>
>
> Documentation/vm/locking is a blast from the past.  In the entire
> git history, it has had precisely Three modifications.  Two of
> those look to be pure renames, and the third was from 2005.
>
> The doc contains such gems as:
>
>> The page_table_lock is grabbed while holding the
>> kernel_lock spinning monitor.
>
>> Page stealers hold kernel_lock to protect against a bunch of
>> races.
>
> Or this which talks about mmap_sem:
>
>> 4. The exception to this rule is expand_stack, which just
>>     takes the read lock and the page_table_lock, this is ok
>>     because it doesn't really modify fields anybody relies on.
>
> expand_stack() doesn't take any locks any more directly, and the
> mmap_sem acquisition was long ago moved up in to the page fault
> code itself.
>
> It could be argued that we need to rewrite this, but it is
> dangerous to leave it as-is.  It will confuse more people than it
> helps.

Heh yeah, when I started few months ago and stumbled upon this doc, 
people in the office suggested that I could send a patch that just 
deletes it. I wasn't that brave, but I agree nevertheless.

> Signed-off-by: Dave Hansen <dave.hansen@intel.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

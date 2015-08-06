Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id 476256B0253
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 09:56:21 -0400 (EDT)
Received: by ykeo23 with SMTP id o23so62525525yke.3
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 06:56:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p11si4203930wik.60.2015.08.06.06.56.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Aug 2015 06:56:20 -0700 (PDT)
Subject: Re: [PATCH V6 1/6] mm: mlock: Refactor mlock, munlock, and munlockall
 code
References: <1438184575-10537-1-git-send-email-emunson@akamai.com>
 <1438184575-10537-2-git-send-email-emunson@akamai.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55C36780.5050508@suse.cz>
Date: Thu, 6 Aug 2015 15:56:16 +0200
MIME-Version: 1.0
In-Reply-To: <1438184575-10537-2-git-send-email-emunson@akamai.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/29/2015 05:42 PM, Eric B Munson wrote:
> Extending the mlock system call is very difficult because it currently
> does not take a flags argument.  A later patch in this set will extend
> mlock to support a middle ground between pages that are locked and
> faulted in immediately and unlocked pages.  To pave the way for the new
> system call, the code needs some reorganization so that all the actual
> entry point handles is checking input and translating to VMA flags.
>
> Signed-off-by: Eric B Munson <emunson@akamai.com>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

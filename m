Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3D4556B0003
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 15:00:41 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id t18so2839734plo.9
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 12:00:41 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id g7-v6si162433plo.380.2018.02.16.12.00.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 12:00:40 -0800 (PST)
Subject: Re: [PATCH 2/3] x86/mm: introduce __PAGE_KERNEL_GLOBAL
References: <20180215132053.6C9B48C8@viggo.jf.intel.com>
 <20180215132055.F341C31E@viggo.jf.intel.com>
 <E0AB2852-C4E0-43D3-ABA7-34117A5516C1@gmail.com>
 <a3dd1676-a2dc-aa02-77ad-51cd3b7a78d5@linux.intel.com>
 <DF43D1DD-42EE-4545-9F54-4BC2395D66EA@gmail.com>
 <0f8abc68-1092-1bae-d244-1adbbee455f9@linux.intel.com>
 <4542D3AE-6A4F-45AD-AD70-8DFA9503071A@gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <9f77b568-d86c-47db-f7a3-ddb931f33af0@linux.intel.com>
Date: Fri, 16 Feb 2018 12:00:38 -0800
MIME-Version: 1.0
In-Reply-To: <4542D3AE-6A4F-45AD-AD70-8DFA9503071A@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, keescook@google.com, Hugh Dickins <hughd@google.com>, Juergen Gross <jgross@suse.com>, x86@kernel.org

On 02/16/2018 11:54 AM, Nadav Amit wrote:
>> But I don't really want to hide that gunk in a macro like that.  It
>> might make more sense as a static inline.  I'll give that a shot and resent.
> Since determining whether PTI is on is done in several places in the kernel,
> maybe there should a single function to determine whether PTI is on,
> something like:
> 
> static inline bool is_pti_on(void)
> {
> 	return IS_ENABLED(CONFIG_PAGE_TABLE_ISOLATION) && 
> 		static_cpu_has(X86_FEATURE_PTI);
> }

We should be able to do it with disabled-features.h and the X86_FEATURE
bit.  I'll look into it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

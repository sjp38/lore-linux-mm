Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id B08F26B0007
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 13:03:52 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id 4so2680302plb.1
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 10:03:52 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id s25si162169pge.187.2018.02.16.10.03.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 10:03:51 -0800 (PST)
Subject: Re: [PATCH 2/3] x86/mm: introduce __PAGE_KERNEL_GLOBAL
References: <20180215132053.6C9B48C8@viggo.jf.intel.com>
 <20180215132055.F341C31E@viggo.jf.intel.com>
 <E0AB2852-C4E0-43D3-ABA7-34117A5516C1@gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <a3dd1676-a2dc-aa02-77ad-51cd3b7a78d5@linux.intel.com>
Date: Fri, 16 Feb 2018 10:03:50 -0800
MIME-Version: 1.0
In-Reply-To: <E0AB2852-C4E0-43D3-ABA7-34117A5516C1@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, jgross@suse.com, x86@kernel.org

On 02/16/2018 09:47 AM, Nadav Amit wrote:
>> But, this also means that we now get *no* opportunity to use
>> global pages with PTI, even for data which is shared such as the
>> cpu_entry_area and entry/exit text.
> 
> Doesna??t this patch change the kernel behavior when the a??noptia??
> parameter is used?

I don't think so.  It takes the "nopti" behavior and effectively makes
it apply everywhere.  So it changes the PTI behavior, not the "nopti"
behavior.

Maybe it would help to quote the code that you think does this instead
of the description. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

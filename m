Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 022606B0033
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 01:41:56 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id c123so20981770pga.17
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 22:41:55 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id o33si5695013plb.588.2017.11.23.22.41.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Nov 2017 22:41:54 -0800 (PST)
Subject: Re: [PATCH 00/23] [v4] KAISER: unmap most of the kernel from
 userspace page tables
References: <20171123003438.48A0EEDE@viggo.jf.intel.com>
 <c55957c0-cf1a-eb8d-c37a-c2b69ada2312@linux.intel.com>
 <20171124063514.36xlqnh5seszy4nu@gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <132d8ad8-a85f-5184-2dee-39a47e22e1ff@linux.intel.com>
Date: Thu, 23 Nov 2017 22:41:53 -0800
MIME-Version: 1.0
In-Reply-To: <20171124063514.36xlqnh5seszy4nu@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org, jgross@suse.com

On 11/23/2017 10:35 PM, Ingo Molnar wrote:
> So the pteval_t changes break the build on most non-x86 architectures (alpha, arm, 
> arm64, etc.), because most of them don't have an asm/pgtable_types.h file.
> 
> pteval_t is an x86-ism.
> 
> So I left out the changes below.

There was a warning on the non-PAE 32-bit builds saying that there was a
shift larger than the type.  I assumed this was because of a reference
to _PAGE_NX, and thus we needed a change to pteval_t.

But, now that I think about it more, that doesn't make sense since
_PAGE_NX should be #defined down to a 0 on those configs unless
something is wrong.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

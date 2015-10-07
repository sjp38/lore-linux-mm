Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id E269F6B0038
	for <linux-mm@kvack.org>; Wed,  7 Oct 2015 16:24:06 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so30837869pad.1
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 13:24:06 -0700 (PDT)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id fn8si60273077pad.50.2015.10.07.13.24.02
        for <linux-mm@kvack.org>;
        Wed, 07 Oct 2015 13:24:02 -0700 (PDT)
Subject: Re: [PATCH 26/26] x86, pkeys: Documentation
References: <20150916174903.E112E464@viggo.jf.intel.com>
 <20150916174913.AF5FEA6D@viggo.jf.intel.com>
 <20150920085554.GA21906@gmail.com> <55FF88BA.6080006@sr71.net>
 <20150924094956.GA30349@gmail.com> <20151003081710.GA26206@gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <56157F60.1000503@sr71.net>
Date: Wed, 7 Oct 2015 13:24:00 -0700
MIME-Version: 1.0
In-Reply-To: <20151003081710.GA26206@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Kees Cook <keescook@google.com>, Brian Gerst <brgerst@gmail.com>

On 10/03/2015 01:17 AM, Ingo Molnar wrote:
> Right now the native x86 PTE format allows two protection related bits for 
> user-space pages:
> 
>   _PAGE_BIT_RW:                   if 0 the page is read-only,  if 1 then it's read-write
>   _PAGE_BIT_NX:                   if 0 the page is executable, if 1 then it's not executable
> 
> As discussed previously, pkeys allows 'true execute only (--x)' mappings.
> 
> Another possibility would be 'true write-only (-w-)' mappings.

How would those work?

Protection Keys has a Write-Disable and an Access-Disable bit.  But,
Access-Disable denies _all_ data access to the region.  There's no way
to allow only writes.

Or am I missing something?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

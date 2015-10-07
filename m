Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 0E9E06B0038
	for <linux-mm@kvack.org>; Wed,  7 Oct 2015 16:39:46 -0400 (EDT)
Received: by obcgx8 with SMTP id gx8so22925279obc.3
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 13:39:45 -0700 (PDT)
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com. [209.85.214.174])
        by mx.google.com with ESMTPS id f3si20116590obe.105.2015.10.07.13.39.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Oct 2015 13:39:45 -0700 (PDT)
Received: by obbda8 with SMTP id da8so22973799obb.1
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 13:39:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <56157F60.1000503@sr71.net>
References: <20150916174903.E112E464@viggo.jf.intel.com> <20150916174913.AF5FEA6D@viggo.jf.intel.com>
 <20150920085554.GA21906@gmail.com> <55FF88BA.6080006@sr71.net>
 <20150924094956.GA30349@gmail.com> <20151003081710.GA26206@gmail.com> <56157F60.1000503@sr71.net>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 7 Oct 2015 13:39:25 -0700
Message-ID: <CALCETrXsQrVstLe4WAAWy-scMmS4Yxe95Lx05j3dmu41L76dMg@mail.gmail.com>
Subject: Re: [PATCH 26/26] x86, pkeys: Documentation
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Ingo Molnar <mingo@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Kees Cook <keescook@google.com>, Brian Gerst <brgerst@gmail.com>

On Wed, Oct 7, 2015 at 1:24 PM, Dave Hansen <dave@sr71.net> wrote:
> On 10/03/2015 01:17 AM, Ingo Molnar wrote:
>> Right now the native x86 PTE format allows two protection related bits for
>> user-space pages:
>>
>>   _PAGE_BIT_RW:                   if 0 the page is read-only,  if 1 then it's read-write
>>   _PAGE_BIT_NX:                   if 0 the page is executable, if 1 then it's not executable
>>
>> As discussed previously, pkeys allows 'true execute only (--x)' mappings.
>>
>> Another possibility would be 'true write-only (-w-)' mappings.
>
> How would those work?
>
> Protection Keys has a Write-Disable and an Access-Disable bit.  But,
> Access-Disable denies _all_ data access to the region.  There's no way
> to allow only writes.

Weird.  I wonder why Intel did that.

I also wonder whether EPT can do write-only.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

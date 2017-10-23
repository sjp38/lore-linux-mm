Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id CA27E6B0033
	for <linux-mm@kvack.org>; Mon, 23 Oct 2017 01:25:48 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p77so4480504lfg.2
        for <linux-mm@kvack.org>; Sun, 22 Oct 2017 22:25:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a13sor8980lfa.28.2017.10.22.22.25.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 22 Oct 2017 22:25:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171023031005.GA5981@bgram>
References: <20171020195934.32108-1-kirill.shutemov@linux.intel.com>
 <20171020195934.32108-2-kirill.shutemov@linux.intel.com> <20171023031005.GA5981@bgram>
From: Nitin Gupta <ngupta@vflare.org>
Date: Sun, 22 Oct 2017 22:25:46 -0700
Message-ID: <CAPkvG_drcJVNzz2WSGzMhwc=oWcv4tQSbtfOM0wdV3_20=yKfA@mail.gmail.com>
Subject: Re: [PATCH 1/4] mm/zsmalloc: Prepare to variable MAX_PHYSMEM_BITS
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Sun, Oct 22, 2017 at 8:10 PM, Minchan Kim <minchan@kernel.org> wrote:
> On Fri, Oct 20, 2017 at 10:59:31PM +0300, Kirill A. Shutemov wrote:
>> With boot-time switching between paging mode we will have variable
>> MAX_PHYSMEM_BITS.
>>
>> Let's use the maximum variable possible for CONFIG_X86_5LEVEL=y
>> configuration to define zsmalloc data structures.
>>
>> The patch introduces MAX_POSSIBLE_PHYSMEM_BITS to cover such case.
>> It also suits well to handle PAE special case.
>>
>> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Nitin Gupta <ngupta@vflare.org>
>> Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
> Acked-by: Minchan Kim <minchan@kernel.org>
>
> Nitin:
>
> I think this patch works and it would be best for Kirill to be able to do.
> So if you have better idea to clean it up, let's make it as another patch
> regardless of this patch series.
>


I was looking into dynamically allocating size_class array to avoid that
compile error, but yes, that can be done in a future patch. So, for this patch:

Reviewed-by: Nitin Gupta <ngupta@vflare.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

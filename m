Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id ABF606B0009
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 05:35:42 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id 128so46919875wmz.1
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 02:35:42 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id b63si6807674wme.9.2016.01.29.02.35.41
        for <linux-mm@kvack.org>;
        Fri, 29 Jan 2016 02:35:41 -0800 (PST)
Date: Fri, 29 Jan 2016 11:35:35 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC 01/13] x86/paravirt: Turn KASAN off for parvirt.o
Message-ID: <20160129103535.GA10187@pd.tnic>
References: <20160110185916.GD22896@pd.tnic>
 <1452516679-32040-1-git-send-email-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1452516679-32040-1-git-send-email-aryabinin@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andy Lutomirski <luto@kernel.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 11, 2016 at 03:51:17PM +0300, Andrey Ryabinin wrote:
> I don't think that this patch is the right way to solve the problem.
> The follow-up patch "x86/kasan: clear kasan_zero_page after TLB flush"
> should fix Andy's problem.

Both applied, thanks.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

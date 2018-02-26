Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4FF8C6B0011
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 14:33:07 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id g13so11963016wrh.23
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 11:33:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l81si3600192wmi.129.2018.02.26.11.33.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Feb 2018 11:33:06 -0800 (PST)
Date: Mon, 26 Feb 2018 20:32:44 +0100
From: Borislav Petkov <bp@suse.de>
Subject: Re: [PATCH 0/5] x86/boot/compressed/64: Prepare trampoline memory
Message-ID: <20180226193244.GH14140@pd.tnic>
References: <20180226180451.86788-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180226180451.86788-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Feb 26, 2018 at 09:04:46PM +0300, Kirill A. Shutemov wrote:
> Borislav, could you check which patch breaks boot for you (if any)?

What is that ontop? tip/master from today or?

-- 
Regards/Gruss,
    Boris.

SUSE Linux GmbH, GF: Felix ImendA?rffer, Jane Smithard, Graham Norton, HRB 21284 (AG NA 1/4 rnberg)
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

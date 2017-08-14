Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 27D0E6B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 12:28:11 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id o83so17539594lfb.3
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 09:28:11 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id 143si3129511ljj.235.2017.08.14.09.28.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 09:28:09 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id x16so6920444lfb.4
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 09:28:09 -0700 (PDT)
Date: Mon, 14 Aug 2017 19:28:07 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] x86/mm: Fix personality(ADDR_NO_RANDOMIZE)
Message-ID: <20170814162807.GP2005@uranus.lan>
References: <20170814155719.74839-1-kirill.shutemov@linux.intel.com>
 <20170814161347.GO2005@uranus.lan>
 <20170814162002.GA9559@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170814162002.GA9559@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Dmitry Safonov <dsafonov@virtuozzo.com>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable <stable@vger.kernel.org>

On Mon, Aug 14, 2017 at 06:20:02PM +0200, Oleg Nesterov wrote:
...
> >
> > Didn't Oleg's patch does the same?
> >
> > https://patchwork.kernel.org/patch/9832697/
> 
> at first glance yes, thanks Cyrill. And note that we do not need another
> PF_RANDOMIZE check.
> 
> > for some reason it's not yet merged.
> 
> because nobody cares ;)

We all care but people are busy ;) Anyway hopefully it get merged soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

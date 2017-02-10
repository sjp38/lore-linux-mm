Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6F2F66B0389
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 17:25:34 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id kq3so13736858wjc.1
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 14:25:34 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id f25si3816500wrc.285.2017.02.10.14.25.33
        for <linux-mm@kvack.org>;
        Fri, 10 Feb 2017 14:25:33 -0800 (PST)
Date: Fri, 10 Feb 2017 23:25:22 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: PCID review?
Message-ID: <20170210222522.udpl6cgai24lg5tf@pd.tnic>
References: <CALCETrVSiS22KLvYxZarexFHa3C7Z-ys_Lt2WV_63b4-tuRpQA@mail.gmail.com>
 <CALCETrVfah6AFG5mZDjVcRrdXKL=07+WC9ES9ZKU90XqVpWCOg@mail.gmail.com>
 <20170209001042.ahxmoqegr6h74mle@techsingularity.net>
 <CALCETrUiUnZ1AWHjx8-__t0DUwryys9O95GABhhpG9AnHwrg9Q@mail.gmail.com>
 <20170210110157.dlejz7szrj3r3pwq@techsingularity.net>
 <CALCETrVjhVqpHTpQ--AVDpWQAb44b265sesou50wSec4rs9sRw@mail.gmail.com>
 <20170210215708.j54cawm23nepgimd@techsingularity.net>
 <CALCETrWToSZZsXHyrXg+YRiyvjRtWd7J0Myvn_mjJJdJoCXr+w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CALCETrWToSZZsXHyrXg+YRiyvjRtWd7J0Myvn_mjJJdJoCXr+w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Mel Gorman <mgorman@techsingularity.net>, Andy Lutomirski <luto@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Fri, Feb 10, 2017 at 02:07:19PM -0800, Andy Lutomirski wrote:
> We'll see.  The main benchmark that I'm relying on (so far) is that
> context switches get way faster, just ping ponging back and forth.  I
> suspect that the TLB refill cost is only a small part.

Is that a microbenchmark or something more "presentable"?

We really should pay attention to the complexity and what that actually
brings us in the end.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

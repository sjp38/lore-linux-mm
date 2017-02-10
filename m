Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 19DD16B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 17:58:59 -0500 (EST)
Received: by mail-vk0-f72.google.com with SMTP id n125so28654699vke.0
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 14:58:59 -0800 (PST)
Received: from mail-ua0-x235.google.com (mail-ua0-x235.google.com. [2607:f8b0:400c:c08::235])
        by mx.google.com with ESMTPS id 65si1009242vkb.131.2017.02.10.14.58.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Feb 2017 14:58:58 -0800 (PST)
Received: by mail-ua0-x235.google.com with SMTP id 96so39336420uaq.3
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 14:58:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170210222522.udpl6cgai24lg5tf@pd.tnic>
References: <CALCETrVSiS22KLvYxZarexFHa3C7Z-ys_Lt2WV_63b4-tuRpQA@mail.gmail.com>
 <CALCETrVfah6AFG5mZDjVcRrdXKL=07+WC9ES9ZKU90XqVpWCOg@mail.gmail.com>
 <20170209001042.ahxmoqegr6h74mle@techsingularity.net> <CALCETrUiUnZ1AWHjx8-__t0DUwryys9O95GABhhpG9AnHwrg9Q@mail.gmail.com>
 <20170210110157.dlejz7szrj3r3pwq@techsingularity.net> <CALCETrVjhVqpHTpQ--AVDpWQAb44b265sesou50wSec4rs9sRw@mail.gmail.com>
 <20170210215708.j54cawm23nepgimd@techsingularity.net> <CALCETrWToSZZsXHyrXg+YRiyvjRtWd7J0Myvn_mjJJdJoCXr+w@mail.gmail.com>
 <20170210222522.udpl6cgai24lg5tf@pd.tnic>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 10 Feb 2017 14:58:37 -0800
Message-ID: <CALCETrXSdcgqiSjGWYDVOk9_-ZRUhuehtnw-RmuqpKRZ7qdG5Q@mail.gmail.com>
Subject: Re: PCID review?
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Mel Gorman <mgorman@techsingularity.net>, Andy Lutomirski <luto@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Fri, Feb 10, 2017 at 2:25 PM, Borislav Petkov <bp@alien8.de> wrote:
> On Fri, Feb 10, 2017 at 02:07:19PM -0800, Andy Lutomirski wrote:
>> We'll see.  The main benchmark that I'm relying on (so far) is that
>> context switches get way faster, just ping ponging back and forth.  I
>> suspect that the TLB refill cost is only a small part.
>
> Is that a microbenchmark or something more "presentable"?

It's a microbenchmark, but the change is fairly large.  It would be
nice to see what the effect is on real workloads.

>
> We really should pay attention to the complexity and what that actually
> brings us in the end.

Agreed.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

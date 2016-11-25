Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id B737F6B0069
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 14:36:07 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id m203so135314784iom.6
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 11:36:07 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0094.hostedemail.com. [216.40.44.94])
        by mx.google.com with ESMTPS id w200si12356655ita.30.2016.11.25.11.36.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Nov 2016 11:36:07 -0800 (PST)
Message-ID: <1480102557.19726.33.camel@perches.com>
Subject: Re: [PATCH 1/2] stacktrace: fix print_stack_trace printing
 timestamp twice
From: Joe Perches <joe@perches.com>
Date: Fri, 25 Nov 2016 11:35:57 -0800
In-Reply-To: <CACT4Y+YB1QBzzdBbPWrq6u2M3B7WuavHZn6KswJi0Qi2DhqDLA@mail.gmail.com>
References: <cover.1478632698.git.andreyknvl@google.com>
	 <9df5bd889e1b980d84aa41e7010e622005fd0665.1478632698.git.andreyknvl@google.com>
	 <2a6c133d-a42e-34ca-108c-b1399b939d65@virtuozzo.com>
	 <CACT4Y+YB1QBzzdBbPWrq6u2M3B7WuavHZn6KswJi0Qi2DhqDLA@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Kostya Serebryany <kcc@google.com>, Peter Zijlstra <peterz@infradead.org>

On Fri, 2016-11-25 at 18:40 +0100, Dmitry Vyukov wrote:
> But should we add KERN_CONT to print_ip_sym instead of duplicating it
> everywhere? Or add print_ip_sym_cont?

There are only a couple dozen uses of print_ip_sym.

It might be better to use "[<%p>] %pS" directly
everywhere and remove print_ip_sym instead to
avoid the KERN_CONT and avoid all possible
interleaved output.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

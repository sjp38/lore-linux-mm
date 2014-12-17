Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 929696B0038
	for <linux-mm@kvack.org>; Wed, 17 Dec 2014 14:58:46 -0500 (EST)
Received: by mail-qg0-f50.google.com with SMTP id z60so1359199qgd.23
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 11:58:46 -0800 (PST)
Received: from mail-qc0-x232.google.com (mail-qc0-x232.google.com. [2607:f8b0:400d:c01::232])
        by mx.google.com with ESMTPS id a2si5797686qam.24.2014.12.17.11.58.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 17 Dec 2014 11:58:45 -0800 (PST)
Received: by mail-qc0-f178.google.com with SMTP id b13so14242013qcw.9
        for <linux-mm@kvack.org>; Wed, 17 Dec 2014 11:58:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5491D0D2.5070103@sr71.net>
References: <5490A5F8.6050504@sr71.net>
	<20141217100810.GA3461@arm.com>
	<CA+55aFyVxOw0upa=At6MmiNYEHzfPz4rE5bZUBCs9h4vKGh1iA@mail.gmail.com>
	<20141217165310.GJ870@arm.com>
	<5491D0D2.5070103@sr71.net>
Date: Wed, 17 Dec 2014 11:58:44 -0800
Message-ID: <CA+55aFze3z_f4hKKg3mf3YcQX6KyDfMO7UmUUhjWx5dtjQZN1A@mail.gmail.com>
Subject: Re: post-3.18 performance regression in TLB flushing code
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Will Deacon <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <peterz@infradead.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Michal Simek <monstr@monstr.eu>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, Dec 17, 2014 at 10:52 AM, Dave Hansen <dave@sr71.net> wrote:
>
> These things are also a little bit noisy, so we're well within the
> margin of error with Linus's fix.
>
> This also holds up on the large system.

Good. I'll commit it asap.

                          Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

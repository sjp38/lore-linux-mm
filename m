Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 97E6D6B03AB
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 12:53:56 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id e69so18226478oic.2
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 09:53:56 -0700 (PDT)
Received: from mail-oi0-x241.google.com (mail-oi0-x241.google.com. [2607:f8b0:4003:c06::241])
        by mx.google.com with ESMTPS id p11si4385634oif.277.2017.07.05.09.53.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jul 2017 09:53:55 -0700 (PDT)
Received: by mail-oi0-x241.google.com with SMTP id n2so21039620oig.3
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 09:53:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170705085657.eghd4xbv7g7shf5v@gmail.com>
References: <cover.1498751203.git.luto@kernel.org> <20170705085657.eghd4xbv7g7shf5v@gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 5 Jul 2017 09:53:55 -0700
Message-ID: <CA+55aFyXuKacpuzPhNtnUkOtXKmKAF3vEyVtCtFXpWTH7LZDoQ@mail.gmail.com>
Subject: Re: [PATCH v4 00/10] PCID and improved laziness
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andy Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, Jul 5, 2017 at 1:56 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> If it's all super stable I plan to tempt Linus with a late merge window pull
> request for all these preparatory patches. (Unless he objects that is. Hint, hint.)

I don't think I'll object. At some point the best testing is "lots of users".

TLB issues are a bitch to debug, but at the same time this is clearly
a "..but at some point we need to bite the bullet" case. I doubt the
series is going to get a lot better.

But yes, please do give it as much testing as humanly possible even
without the wider coverage by random people.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

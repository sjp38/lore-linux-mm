Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 154D96B0044
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 12:36:57 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so1622751qcs.14
        for <linux-mm@kvack.org>; Wed, 15 Aug 2012 09:36:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120809083127.GC14102@arm.com>
References: <1344324343-3817-1-git-send-email-walken@google.com>
 <1344324343-3817-4-git-send-email-walken@google.com> <CANN689EOZ64V_AO8B6N0-_B0_HdQZVk3dH8Ce5c=m5Q=ySDKUg@mail.gmail.com>
 <20120809083127.GC14102@arm.com>
From: Catalin Marinas <catalin.marinas@arm.com>
Date: Wed, 15 Aug 2012 17:36:35 +0100
Message-ID: <CAHkRjk4pQOktEGFZy9Jd5NDth8f_+JUC0OrgcRUaCFGUEUOTKg@mail.gmail.com>
Subject: Re: [PATCH 3/5] kmemleak: use rbtree instead of prio tree
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: "riel@redhat.com" <riel@redhat.com>, "peterz@infradead.org" <peterz@infradead.org>, "vrajesh@umich.edu" <vrajesh@umich.edu>, "daniel.santos@pobox.com" <daniel.santos@pobox.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "dwmw2@infradead.org" <dwmw2@infradead.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>

On 9 August 2012 09:31, Catalin Marinas <catalin.marinas@arm.com> wrote:
> On Wed, Aug 08, 2012 at 06:07:39PM +0100, Michel Lespinasse wrote:
>> kmemleak uses a tree where each node represents an allocated memory object
>> in order to quickly find out what object a given address is part of.
>> However, the objects don't overlap, so rbtrees are a better choice than
>> prio tree for this use. They are both faster and have lower memory overhead.
>>
>> Tested by booting a kernel with kmemleak enabled, loading the kmemleak_test
>> module, and looking for the expected messages.
>>
>> Signed-off-by: Michel Lespinasse <walken@google.com>
>
> The patch looks fine to me but I'll give it a test later today and let
> you know.

Couldn't test it because the patch got messed up somewhere on the
email path (tabs replaced with spaces). Is there a Git tree I can grab
it from (or you could just send it to me separately as attachment)?

Thanks,

Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

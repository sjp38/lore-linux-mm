Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id DE18A6B037B
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 03:54:40 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id w78so1317684oiw.6
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 00:54:40 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v50si796534otf.455.2017.12.06.00.54.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Dec 2017 00:54:35 -0800 (PST)
Subject: Re: [PATCH 0/2] mm: introduce MAP_FIXED_SAFE
References: <20171129144219.22867-1-mhocko@kernel.org>
 <CAGXu5jLa=b2HhjWXXTQunaZuz11qUhm5aNXHpS26jVqb=G-gfw@mail.gmail.com>
 <20171130065835.dbw4ajh5q5whikhf@dhcp22.suse.cz> <20171201152640.GA3765@rei>
 <87wp20e9wf.fsf@concordia.ellerman.id.au>
 <20171206045433.GQ26021@bombadil.infradead.org>
 <20171206070355.GA32044@bombadil.infradead.org>
 <5f4fc834-274a-b8f1-bda0-5bcddc5902ed@nvidia.com>
 <b4cc4225-d49c-51b0-dd18-e8038b5136e1@redhat.com>
 <27ee1755-76d8-f086-5760-9c973b31108a@nvidia.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <66677640-5c4a-0758-9560-e45de2d5ba06@redhat.com>
Date: Wed, 6 Dec 2017 09:54:30 +0100
MIME-Version: 1.0
In-Reply-To: <27ee1755-76d8-f086-5760-9c973b31108a@nvidia.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Michael Ellerman <mpe@ellerman.id.au>
Cc: Cyril Hrubis <chrubis@suse.cz>, Michal Hocko <mhocko@kernel.org>, Kees Cook <keescook@chromium.org>, Linux API <linux-api@vger.kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Joel Stanley <joel@jms.id.au>

On 12/06/2017 09:06 AM, John Hubbard wrote:
> On 12/05/2017 11:35 PM, Florian Weimer wrote:
>> On 12/06/2017 08:33 AM, John Hubbard wrote:
>>> In that case, maybe:
>>>
>>>  A A A A  MAP_EXACT
>>>
>>> ? ...because that's the characteristic behavior.
>>
>> Is that true?A  mmap still silently rounding up the length to the page size, I assume, so even that name is misleading.
> 
> Hi Florian,
> 
> Not as far as I can tell, it's not doing that.
> 
> For both MAP_FIXED, and this new flag, the documented (and actual)
> behavior is *not* to do any such rounding. Instead, the requested
> input address is required to be page-aligned itself, and mmap()
> should be honoring the exact addr.

I meant the length, not the address.

Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

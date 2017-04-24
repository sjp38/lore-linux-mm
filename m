Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6A0B86B0297
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 16:33:30 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 184so5519080wmy.18
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 13:33:30 -0700 (PDT)
Received: from outpost3.zedat.fu-berlin.de (outpost3.zedat.fu-berlin.de. [130.133.4.78])
        by mx.google.com with ESMTPS id a60si3808392edf.157.2017.04.24.13.33.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 13:33:28 -0700 (PDT)
Subject: Re: Question on the five-level page table support patches
References: <030ea57b-5f6c-13d8-02f7-b245a754a87d@physik.fu-berlin.de>
 <CALCETrUcB7STNjVw=WBZdFfz_H1DKcLnj3HHtnGaHGQ1UY8Zrw@mail.gmail.com>
 <20170424130311.GR4021@tassilo.jf.intel.com>
From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Message-ID: <8f8467b5-70e6-466b-f53b-1c64622ba82d@physik.fu-berlin.de>
Date: Mon, 24 Apr 2017 22:33:22 +0200
MIME-Version: 1.0
In-Reply-To: <20170424130311.GR4021@tassilo.jf.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>, Andy Lutomirski <luto@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@suse.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 04/24/2017 03:03 PM, Andi Kleen wrote:
> In old Linux hint was a search hint, so if there isn't a hole
> at the hinted area it will search starting from there for a hole
> instead of giving up immediately.

Yep, that's what I meant. It used to work like that and it still
works like that on NetBSD, for example. Although it has apparently
been a long time since it changed [1].

> Now it just gives up, which means every user has to implement
> their own search.

Correct. And the resulting code is usually ugly and inefficient [2].

> Yes I ran into the same problem and it's annoying. It broke
> originally when top down mmap was added I believe
> 
> Before the augmented rbtree it was potentially very expensive, but now
> it should be cheap.

I'm not sure whether I understand what that means.

Thanks,
Adrian

> [1] http://lkml.iu.edu/hypermail/linux/kernel/0305.2/0828.html
> [2] https://hg.mozilla.org/mozilla-central/rev/dfaafbaaa291

-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

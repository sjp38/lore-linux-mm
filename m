Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id BFC7A6B0005
	for <linux-mm@kvack.org>; Sun,  3 Jul 2016 13:10:45 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a69so347942873pfa.1
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 10:10:45 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id b2si4679711pav.216.2016.07.03.10.10.42
        for <linux-mm@kvack.org>;
        Sun, 03 Jul 2016 10:10:42 -0700 (PDT)
Subject: Re: [PATCH 6/6] x86: Fix stray A/D bit setting into non-present PTEs
References: <20160701001209.7DA24D1C@viggo.jf.intel.com>
 <20160701001218.3D316260@viggo.jf.intel.com>
 <CA+55aFwm74uiqwsV5dvVMDBAthwmHub3J3Wz9cso0PpgVTHUPA@mail.gmail.com>
 <CAMzpN2iLBKF7vK3TuTPwYn2nZOw2q_Pn=q+g6pNuVs0k6Xd5LQ@mail.gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <5779470F.8020205@sr71.net>
Date: Sun, 3 Jul 2016 10:10:39 -0700
MIME-Version: 1.0
In-Reply-To: <CAMzpN2iLBKF7vK3TuTPwYn2nZOw2q_Pn=q+g6pNuVs0k6Xd5LQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Gerst <brgerst@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Borislav Petkov <bp@alien8.de>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>

On 06/30/2016 08:06 PM, Brian Gerst wrote:
>> > It's not like anybody will ever care about 32-bit page tables on
>> > Knights Landing anyway.
> Could this affect a 32-bit guest VM?

This isn't about 32-bit *mode*.  It's about using the the 32-bit 2-level
_paging_ mode that supports only 4GB virtual and 4GB physical addresses.
 That mode also doesn't support the No-eXecute (NX) bit, which basically
everyone needs today for its security benefits.

Even the little Quark CPU supports PAE (64-bit page tables).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

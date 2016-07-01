Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2D3CE828E4
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 01:43:11 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id u81so108894709oia.3
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 22:43:11 -0700 (PDT)
Received: from mail-oi0-x22d.google.com (mail-oi0-x22d.google.com. [2607:f8b0:4003:c06::22d])
        by mx.google.com with ESMTPS id c54si831676otd.71.2016.06.30.22.43.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jun 2016 22:43:10 -0700 (PDT)
Received: by mail-oi0-x22d.google.com with SMTP id s66so97073074oif.1
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 22:43:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5775F418.2000803@sr71.net>
References: <20160701001209.7DA24D1C@viggo.jf.intel.com> <20160701001218.3D316260@viggo.jf.intel.com>
 <CA+55aFwm74uiqwsV5dvVMDBAthwmHub3J3Wz9cso0PpgVTHUPA@mail.gmail.com> <5775F418.2000803@sr71.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 30 Jun 2016 22:43:09 -0700
Message-ID: <CA+55aFydq3kpT-mzPqcU1_1h=+vSUj6RmQwiz5NVnfY4HfSjXw@mail.gmail.com>
Subject: Re: [PATCH 6/6] x86: Fix stray A/D bit setting into non-present PTEs
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Borislav Petkov <bp@alien8.de>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>

On Thu, Jun 30, 2016 at 9:39 PM, Dave Hansen <dave@sr71.net> wrote:
>
> I think what you suggest will work if we don't consider A/D in
> pte_none().  I think there are a bunch of code path where assume that
> !pte_present() && !pte_none() means swap.

Yeah, we would need to change pte_none() to mask off D/A, but I think
that might be the only real change needed (other than making sure that
we don't use the bits in the swap entries, I didn't look at that part
at all)

           Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

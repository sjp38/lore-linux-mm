Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 458F46B0253
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 10:37:38 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e189so239443408pfa.2
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 07:37:38 -0700 (PDT)
Received: from out03.mta.xmission.com (out03.mta.xmission.com. [166.70.13.233])
        by mx.google.com with ESMTPS id 68si4330382pff.189.2016.07.01.07.37.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jul 2016 07:37:37 -0700 (PDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <20160701001209.7DA24D1C@viggo.jf.intel.com>
	<20160701001218.3D316260@viggo.jf.intel.com>
	<CA+55aFwm74uiqwsV5dvVMDBAthwmHub3J3Wz9cso0PpgVTHUPA@mail.gmail.com>
	<5775F418.2000803@sr71.net>
	<CA+55aFydq3kpT-mzPqcU1_1h=+vSUj6RmQwiz5NVnfY4HfSjXw@mail.gmail.com>
Date: Fri, 01 Jul 2016 09:25:10 -0500
In-Reply-To: <CA+55aFydq3kpT-mzPqcU1_1h=+vSUj6RmQwiz5NVnfY4HfSjXw@mail.gmail.com>
	(Linus Torvalds's message of "Thu, 30 Jun 2016 22:43:09 -0700")
Message-ID: <874m89cu61.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [PATCH 6/6] x86: Fix stray A/D bit setting into non-present PTEs
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Hansen <dave@sr71.net>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Borislav Petkov <bp@alien8.de>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>

Linus Torvalds <torvalds@linux-foundation.org> writes:

> On Thu, Jun 30, 2016 at 9:39 PM, Dave Hansen <dave@sr71.net> wrote:
>>
>> I think what you suggest will work if we don't consider A/D in
>> pte_none().  I think there are a bunch of code path where assume that
>> !pte_present() && !pte_none() means swap.
>
> Yeah, we would need to change pte_none() to mask off D/A, but I think
> that might be the only real change needed (other than making sure that
> we don't use the bits in the swap entries, I didn't look at that part
> at all)

It looks like __pte_to_swp_entry also needs to be changed to mask out
those bits when the swap code reads pte entries.  For all of the same
reasons as pte_none.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

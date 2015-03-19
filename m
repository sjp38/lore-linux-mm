Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 567266B0070
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 14:09:16 -0400 (EDT)
Received: by igcau2 with SMTP id au2so15564809igc.1
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 11:09:16 -0700 (PDT)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com. [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id 82si2075960ioz.62.2015.03.19.11.09.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Mar 2015 11:09:15 -0700 (PDT)
Received: by ignm3 with SMTP id m3so15633818ign.0
        for <linux-mm@kvack.org>; Thu, 19 Mar 2015 11:09:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150319141022.GD3087@suse.de>
References: <20150312131045.GE3406@suse.de>
	<CA+55aFx=81BGnQFNhnAGu6CetL7yifPsnD-+v7Y6QRqwgH47gQ@mail.gmail.com>
	<20150312184925.GH3406@suse.de>
	<20150317070655.GB10105@dastard>
	<CA+55aFzdLnFdku-gnm3mGbeS=QauYBNkFQKYXJAGkrMd2jKXhw@mail.gmail.com>
	<20150317205104.GA28621@dastard>
	<CA+55aFzSPcNgxw4GC7aAV1r0P5LniyVVC66COz=3cgMcx73Nag@mail.gmail.com>
	<20150317220840.GC28621@dastard>
	<CA+55aFwne-fe_Gg-_GTUo+iOAbbNpLBa264JqSFkH79EULyAqw@mail.gmail.com>
	<CA+55aFy-Mw74rAdLMMMUgnsG3ZttMWVNGz7CXZJY7q9fqyRYfg@mail.gmail.com>
	<20150319141022.GD3087@suse.de>
Date: Thu, 19 Mar 2015 11:09:15 -0700
Message-ID: <CA+55aFwTcw2rTjPM_EOjPeKNWwdfNVazx+O=YAFXPWw1h==Tgw@mail.gmail.com>
Subject: Re: [PATCH 4/4] mm: numa: Slow PTE scan rate if migration failures occur
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, ppc-dev <linuxppc-dev@lists.ozlabs.org>

On Thu, Mar 19, 2015 at 7:10 AM, Mel Gorman <mgorman@suse.de> wrote:
> -       if (!pmd_dirty(pmd))
> +       /* See similar comment in do_numa_page for explanation */
> +       if (!(vma->vm_flags & VM_WRITE))

Yeah, that would certainly be a whole lot more obvious than all the
"if this particular pte/pmd looks like X" tests.

So that, together with scanning rate improvements (this *does* seem to
be somewhat chaotic, so it's quite possible that the current scanning
rate thing is just fairly unstable) is likely the right thing. I'd
just like to _understand_ why that write/dirty bit makes such a
difference. I thought I understood what was going on, and was happy,
and then Dave come with his crazy numbers.

Damn you Dave, and damn your numbers and "facts" and stuff. Sometimes
I much prefer ignorant bliss.

                           Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

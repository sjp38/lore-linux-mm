Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9AF616B0273
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 17:15:36 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id g202so8400510ita.4
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 14:15:36 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u185sor3411632itf.144.2018.01.17.14.15.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jan 2018 14:15:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <87aea433-ba6b-8543-d925-3ef36911f124@linux.intel.com>
References: <CA+55aFwvgm+KKkRLaFsuAjTdfQooS=UaMScC0CbZQ9WnX_AF=g@mail.gmail.com>
 <201801160115.w0G1FOIG057203@www262.sakura.ne.jp> <CA+55aFxOn5n4O2JNaivi8rhDmeFhTQxEHD4xE33J9xOrFu=7kQ@mail.gmail.com>
 <201801170233.JDG21842.OFOJMQSHtOFFLV@I-love.SAKURA.ne.jp>
 <CA+55aFyxyjN0Mqnz66B4a0R+uR8DdfxdMhcg5rJVi8LwnpSRfA@mail.gmail.com>
 <201801172008.CHH39543.FFtMHOOVSQJLFO@I-love.SAKURA.ne.jp>
 <CA+55aFw_itrZGTkDPL41DtwCBEBHmxXsucp5HUbNDX9hwOFddw@mail.gmail.com> <87aea433-ba6b-8543-d925-3ef36911f124@linux.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 17 Jan 2018 14:15:34 -0800
Message-ID: <CA+55aFz3e073ng0s5MA9+_a0r_TMfAjNCKqKuWSAv=uRs2CmuA@mail.gmail.com>
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Tony Luck <tony.luck@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>

On Wed, Jan 17, 2018 at 2:00 PM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
>
> I thought that page_zone_id() stuff was there to prevent this kind of
> cross-zone stuff from happening.

Ahh, that was the part I missed. Yeah looks like that checks things
properly. Although the mask generation is *so* confusing that I
stopped following it and will just take your word for it ;)

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

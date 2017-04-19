Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3495C6B039F
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 18:50:07 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id x86so39620880ioe.5
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 15:50:07 -0700 (PDT)
Received: from mail-io0-x236.google.com (mail-io0-x236.google.com. [2607:f8b0:4001:c06::236])
        by mx.google.com with ESMTPS id r10si16634731itc.109.2017.04.19.15.50.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 15:50:03 -0700 (PDT)
Received: by mail-io0-x236.google.com with SMTP id r16so40266663ioi.2
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 15:50:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170419081701.GC29789@dhcp22.suse.cz>
References: <201704190541.v3J5fUE3054131@www262.sakura.ne.jp>
 <20170419071039.GB28263@dhcp22.suse.cz> <201704190726.v3J7QAiC076509@www262.sakura.ne.jp>
 <20170419075712.GB29789@dhcp22.suse.cz> <CAMuHMdVmJrr6_sGeU4oxH5fn10BRdLC5nOEePN05p3kJ1x3YBQ@mail.gmail.com>
 <20170419081701.GC29789@dhcp22.suse.cz>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 19 Apr 2017 15:50:01 -0700
Message-ID: <CA+55aFxQOJp0jq4Z9pFQzZtyc7KHapVT=ZbYyUufyGQhY=DvkQ@mail.gmail.com>
Subject: Re: Re: Re: "mm: move pcp and lru-pcp draining into single wq" broke
 resume from s2ram
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux PM list <linux-pm@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Linux-Renesas <linux-renesas-soc@vger.kernel.org>, Tejun Heo <tj@kernel.org>

On Wed, Apr 19, 2017 at 1:17 AM, Michal Hocko <mhocko@kernel.org> wrote:
>
> Thanks for the testing. Linus will you take the patch from this thread
> or you prefer a resend?

I'll take it from this branch since I'm looking at it now, but in
general I prefer resends just because finding patches deep in some
discussion is very iffy.

I get too much email, so it really helps to make the patches more
explicit than this...

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

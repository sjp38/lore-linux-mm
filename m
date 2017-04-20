Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 550506B03B7
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 02:53:33 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g31so4586562wrg.15
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 23:53:33 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t18si7630235wra.90.2017.04.19.23.53.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Apr 2017 23:53:32 -0700 (PDT)
Date: Thu, 20 Apr 2017 08:53:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Re: Re: "mm: move pcp and lru-pcp draining into single wq" broke
 resume from s2ram
Message-ID: <20170420065327.GA15781@dhcp22.suse.cz>
References: <201704190541.v3J5fUE3054131@www262.sakura.ne.jp>
 <20170419071039.GB28263@dhcp22.suse.cz>
 <201704190726.v3J7QAiC076509@www262.sakura.ne.jp>
 <20170419075712.GB29789@dhcp22.suse.cz>
 <CAMuHMdVmJrr6_sGeU4oxH5fn10BRdLC5nOEePN05p3kJ1x3YBQ@mail.gmail.com>
 <20170419081701.GC29789@dhcp22.suse.cz>
 <CA+55aFxQOJp0jq4Z9pFQzZtyc7KHapVT=ZbYyUufyGQhY=DvkQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxQOJp0jq4Z9pFQzZtyc7KHapVT=ZbYyUufyGQhY=DvkQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux PM list <linux-pm@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Linux-Renesas <linux-renesas-soc@vger.kernel.org>, Tejun Heo <tj@kernel.org>

On Wed 19-04-17 15:50:01, Linus Torvalds wrote:
> On Wed, Apr 19, 2017 at 1:17 AM, Michal Hocko <mhocko@kernel.org> wrote:
> >
> > Thanks for the testing. Linus will you take the patch from this thread
> > or you prefer a resend?
> 
> I'll take it from this branch since I'm looking at it now, but in
> general I prefer resends just because finding patches deep in some
> discussion is very iffy.

Yeah, I perfectly understand this and that's why I've asked. Thanks for
taking the patch!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

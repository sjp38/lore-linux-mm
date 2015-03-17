Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8353B6B0038
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 21:48:34 -0400 (EDT)
Received: by ykfs63 with SMTP id s63so24958976ykf.2
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 18:48:34 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id m42si5822688yho.169.2015.03.16.18.48.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Mar 2015 18:48:33 -0700 (PDT)
Message-ID: <550787E7.1030604@oracle.com>
Date: Mon, 16 Mar 2015 21:48:23 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: kill kmemcheck
References: <1426074547-21888-1-git-send-email-sasha.levin@oracle.com>	<20150311081909.552e2052@grimm.local.home>	<55003666.3020100@oracle.com>	<20150311084034.04ce6801@grimm.local.home>	<55004595.7020304@oracle.com>	<20150311102636.6b4110a8@gandalf.local.home>	<55005491.5080809@oracle.com> <20150311105210.1855c95e@gandalf.local.home>
In-Reply-To: <20150311105210.1855c95e@gandalf.local.home>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, netdev@vger.kernel.org, linux-arch@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On 03/11/2015 10:52 AM, Steven Rostedt wrote:
>> > Could you try KASan for your use case and see if it potentially uncovers
>> > anything new?
> The problem is, I don't have a setup to build with the latest compiler.
> 
> I could build with my host compiler (that happens to be 4.9.2), but it
> would take a while to build, and is not part of my work flow.
> 
> 4.9.2 is very new, I think it's a bit premature to declare that the
> only way to test memory allocations is with the latest and greatest
> kernel.
> 
> But if kmemcheck really doesn't work anymore, than perhaps we should
> get rid of it.

Steven,


Since the only objection raised was the too-newiness of GCC 4.9.2/5.0, what
would you consider a good time-line for removal?

I haven't heard any "over my dead body" objections, so I guess that trying
to remove it while no distribution was shipping the compiler that would make
it possible was premature.

Although, on the other hand, I'd be happy if we can have a reasonable date
(that is before my kid goes to college), preferably even before the next
LSF/MM so that we could have a mission accomplished thingie with a round
of beers and commemorative t-shirts.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

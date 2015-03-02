Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8EF9F6B006E
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 07:40:07 -0500 (EST)
Received: by mail-ob0-f182.google.com with SMTP id nt9so30424273obb.13
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 04:40:07 -0800 (PST)
Received: from mail-oi0-x22e.google.com (mail-oi0-x22e.google.com. [2607:f8b0:4003:c06::22e])
        by mx.google.com with ESMTPS id u19si1517517oia.103.2015.03.02.04.40.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 04:40:06 -0800 (PST)
Received: by mail-oi0-f46.google.com with SMTP id x69so26707478oia.5
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 04:40:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150302123149.GK21418@twins.programming.kicks-ass.net>
References: <1411740233-28038-1-git-send-email-steve.capper@linaro.org>
	<54F06636.6080905@redhat.com>
	<54F3C6AD.50300@redhat.com>
	<938476184.27970130.1425275915893.JavaMail.zimbra@zmail15.collab.prod.int.phx2.redhat.com>
	<20150302105011.GD22541@e104818-lin.cambridge.arm.com>
	<1172437505.28092883.1425294374323.JavaMail.zimbra@zmail15.collab.prod.int.phx2.redhat.com>
	<20150302123149.GK21418@twins.programming.kicks-ass.net>
Date: Mon, 2 Mar 2015 13:40:06 +0100
Message-ID: <CAMuHMdVmL9HV5yBgnNtGWNmVN0NQa-EXtOsLkZ1G8PCkT9TWew@mail.gmail.com>
Subject: Re: PMD update corruption (sync question)
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Jon Masters <jcm@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, gary.robertson@linaro.org, Steve Capper <steve.capper@linaro.org>, Mark Rutland <mark.rutland@arm.com>, Hugh Dickins <hughd@google.com>, christoffer.dall@linaro.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Russell King <linux@arm.linux.org.uk>, Linux-Arch <linux-arch@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Will Deacon <will.deacon@arm.com>, dann.frazier@canonical.com, anders.roxell@linaro.org

On Mon, Mar 2, 2015 at 1:31 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> Q: What is the most annoying thing in e-mail?

"Sent from my #ARM Powered Mobile Device" ;-)

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

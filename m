Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id D443F6B0038
	for <linux-mm@kvack.org>; Tue, 30 Dec 2014 16:45:01 -0500 (EST)
Received: by mail-qa0-f43.google.com with SMTP id n4so7345571qaq.2
        for <linux-mm@kvack.org>; Tue, 30 Dec 2014 13:45:01 -0800 (PST)
Received: from mail-qa0-x22c.google.com (mail-qa0-x22c.google.com. [2607:f8b0:400d:c00::22c])
        by mx.google.com with ESMTPS id c90si30259023qgc.123.2014.12.30.13.45.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 30 Dec 2014 13:45:00 -0800 (PST)
Received: by mail-qa0-f44.google.com with SMTP id bm13so10675267qab.31
        for <linux-mm@kvack.org>; Tue, 30 Dec 2014 13:45:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141230134230.GB15546@dhcp22.suse.cz>
References: <20141217130807.GB24704@dhcp22.suse.cz>
	<201412182111.JCE48417.QFOJSFtMOHFLOV@I-love.SAKURA.ne.jp>
	<20141218153341.GB832@dhcp22.suse.cz>
	<201412192122.DJI13055.OOVSQLOtFHFFMJ@I-love.SAKURA.ne.jp>
	<20141220020331.GM1942@devil.localdomain>
	<201412202141.ADF87596.tOSLJHFFOOFMVQ@I-love.SAKURA.ne.jp>
	<20141220223504.GI15665@dastard>
	<20141229174030.GD32618@dhcp22.suse.cz>
	<CA+55aFw5uQpHkSWnKy-CKGgg1QQ6-kix+kfqEcQWKXx2bU1q4A@mail.gmail.com>
	<20141229193312.GA31288@dhcp22.suse.cz>
	<20141230134230.GB15546@dhcp22.suse.cz>
Date: Tue, 30 Dec 2014 13:45:00 -0800
Message-ID: <CA+55aFyxQcZVWASP-9dKs3_vUSPOiY2mGGLyY9HhWaG-fT3+7A@mail.gmail.com>
Subject: Re: [PATCH] mm: get rid of radix tree gfp mask for pagecache_get_page
 (was: Re: How to handle TIF_MEMDIE stalls?)
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Dave Chinner <dchinner@redhat.com>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, Dec 30, 2014 at 5:42 AM, Michal Hocko <mhocko@suse.cz> wrote:
>
> I've noticed you have taken the patch to mm tree already. I have
> realized I haven't marked it for stable which is worth it IMO because
> debugging nasty reclaim recursion bugs is definitely a pain and might
> fix one and even if it doesn't it is rather straightforward and
> shouldn't break anything. So if nobody has anything against I would mark
> this for stable 3.16+ AFAICS.

I already applied it (as commit 45f87de57f8f), so if you think it's
stable material - and I agree that it looks that way - you should just
email stable@vger.kernel.org about it.

I think it might be a good idea to wait a week or two to make sure it
doesn't have any unexpected side effects.

                        Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

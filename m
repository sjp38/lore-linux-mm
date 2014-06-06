Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id 23B676B0035
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 07:03:09 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id u57so2628972wes.18
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 04:03:08 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dc5si20502683wib.85.2014.06.06.04.03.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 06 Jun 2014 04:03:07 -0700 (PDT)
Date: Fri, 6 Jun 2014 13:03:07 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Interactivity regression since v3.11 in mm/vmscan.c
Message-ID: <20140606110306.GD26253@dhcp22.suse.cz>
References: <53905594d284f_71f12992fc6a@nysa.notmuch>
 <20140605133747.GB2942@dhcp22.suse.cz>
 <CAMP44s1kk8PyMd603g0C9yvHuuUZXzwwNQHpM8Abghvc_Os-SQ@mail.gmail.com>
 <20140606091620.GC26253@dhcp22.suse.cz>
 <CAMP44s2K-kZ8yLC3NPbpO9Z9ykQeySXW+cRiZ_NpLUMzDuiq9g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMP44s2K-kZ8yLC3NPbpO9Z9ykQeySXW+cRiZ_NpLUMzDuiq9g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Felipe Contreras <felipe.contreras@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>

On Fri 06-06-14 05:33:28, Felipe Contreras wrote:
> On Fri, Jun 6, 2014 at 4:16 AM, Michal Hocko <mhocko@suse.cz> wrote:
> 
> > Mel has a nice systemtap script (attached) to watch for stalls. Maybe
> > you can give it a try?
> 
> Is there any special configurations I should enable?

You need debuginfo and systemtap AFAIK. I haven't used this script
myself.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

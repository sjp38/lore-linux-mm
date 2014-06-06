Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 6B4E66B0035
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 06:33:29 -0400 (EDT)
Received: by mail-qa0-f54.google.com with SMTP id j15so3460006qaq.27
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 03:33:29 -0700 (PDT)
Received: from mail-qg0-x22d.google.com (mail-qg0-x22d.google.com [2607:f8b0:400d:c04::22d])
        by mx.google.com with ESMTPS id c18si12172064qaq.0.2014.06.06.03.33.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 06 Jun 2014 03:33:28 -0700 (PDT)
Received: by mail-qg0-f45.google.com with SMTP id z60so3871796qgd.4
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 03:33:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140606091620.GC26253@dhcp22.suse.cz>
References: <53905594d284f_71f12992fc6a@nysa.notmuch>
	<20140605133747.GB2942@dhcp22.suse.cz>
	<CAMP44s1kk8PyMd603g0C9yvHuuUZXzwwNQHpM8Abghvc_Os-SQ@mail.gmail.com>
	<20140606091620.GC26253@dhcp22.suse.cz>
Date: Fri, 6 Jun 2014 05:33:28 -0500
Message-ID: <CAMP44s2K-kZ8yLC3NPbpO9Z9ykQeySXW+cRiZ_NpLUMzDuiq9g@mail.gmail.com>
Subject: Re: Interactivity regression since v3.11 in mm/vmscan.c
From: Felipe Contreras <felipe.contreras@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>

On Fri, Jun 6, 2014 at 4:16 AM, Michal Hocko <mhocko@suse.cz> wrote:

> Mel has a nice systemtap script (attached) to watch for stalls. Maybe
> you can give it a try?

Is there any special configurations I should enable?

I get this:
semantic error: unresolved arity-1 global array name, missing global
declaration?: identifier 'name' at /tmp/stapd6pu9A:4:2
        source: name[t]=execname()
                ^

Pass 2: analysis failed.  [man error::pass2]
Number of similar error messages suppressed: 71.
Rerun with -v to see them.
Unexpected exit of STAP script at
/home/felipec/Downloads/watch-dstate-new.pl line 320.



-- 
Felipe Contreras

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

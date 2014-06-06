Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id 2B1436B00AE
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 19:11:15 -0400 (EDT)
Received: by mail-qa0-f52.google.com with SMTP id cm18so4960718qab.25
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 16:11:15 -0700 (PDT)
Received: from mail-qa0-x22c.google.com (mail-qa0-x22c.google.com [2607:f8b0:400d:c00::22c])
        by mx.google.com with ESMTPS id dc7si14786634qcb.24.2014.06.06.16.11.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 06 Jun 2014 16:11:14 -0700 (PDT)
Received: by mail-qa0-f44.google.com with SMTP id j7so4914465qaq.17
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 16:11:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAMP44s2K-kZ8yLC3NPbpO9Z9ykQeySXW+cRiZ_NpLUMzDuiq9g@mail.gmail.com>
References: <53905594d284f_71f12992fc6a@nysa.notmuch>
	<20140605133747.GB2942@dhcp22.suse.cz>
	<CAMP44s1kk8PyMd603g0C9yvHuuUZXzwwNQHpM8Abghvc_Os-SQ@mail.gmail.com>
	<20140606091620.GC26253@dhcp22.suse.cz>
	<CAMP44s2K-kZ8yLC3NPbpO9Z9ykQeySXW+cRiZ_NpLUMzDuiq9g@mail.gmail.com>
Date: Fri, 6 Jun 2014 18:11:14 -0500
Message-ID: <CAMP44s0pyjRyBM4u5-irCt0DbR96yR=hok+VZgC1KS782edN3w@mail.gmail.com>
Subject: Re: Interactivity regression since v3.11 in mm/vmscan.c
From: Felipe Contreras <felipe.contreras@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>

On Fri, Jun 6, 2014 at 5:33 AM, Felipe Contreras
<felipe.contreras@gmail.com> wrote:
> On Fri, Jun 6, 2014 at 4:16 AM, Michal Hocko <mhocko@suse.cz> wrote:
>
>> Mel has a nice systemtap script (attached) to watch for stalls. Maybe
>> you can give it a try?
>
> Is there any special configurations I should enable?
>
> I get this:
> semantic error: unresolved arity-1 global array name, missing global
> declaration?: identifier 'name' at /tmp/stapd6pu9A:4:2
>         source: name[t]=execname()
>                 ^
>
> Pass 2: analysis failed.  [man error::pass2]
> Number of similar error messages suppressed: 71.
> Rerun with -v to see them.
> Unexpected exit of STAP script at
> /home/felipec/Downloads/watch-dstate-new.pl line 320.

Actually I debugged the problem, and it's that the format of the
script is DOS, not UNIX. After changing the format the script works.

However, it's not returning anything. It's running, but doesn't seem
to find any stalls.

-- 
Felipe Contreras

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

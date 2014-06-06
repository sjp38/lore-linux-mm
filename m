Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 9C9996B0035
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 08:54:24 -0400 (EDT)
Received: by mail-qg0-f41.google.com with SMTP id j5so4317844qga.28
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 05:54:24 -0700 (PDT)
Received: from mail-qa0-x231.google.com (mail-qa0-x231.google.com [2607:f8b0:400d:c00::231])
        by mx.google.com with ESMTPS id j63si12691061qgd.46.2014.06.06.05.54.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 06 Jun 2014 05:54:24 -0700 (PDT)
Received: by mail-qa0-f49.google.com with SMTP id cm18so3587965qab.8
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 05:54:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140606110306.GD26253@dhcp22.suse.cz>
References: <53905594d284f_71f12992fc6a@nysa.notmuch>
	<20140605133747.GB2942@dhcp22.suse.cz>
	<CAMP44s1kk8PyMd603g0C9yvHuuUZXzwwNQHpM8Abghvc_Os-SQ@mail.gmail.com>
	<20140606091620.GC26253@dhcp22.suse.cz>
	<CAMP44s2K-kZ8yLC3NPbpO9Z9ykQeySXW+cRiZ_NpLUMzDuiq9g@mail.gmail.com>
	<20140606110306.GD26253@dhcp22.suse.cz>
Date: Fri, 6 Jun 2014 07:54:23 -0500
Message-ID: <CAMP44s2M=xigBQCKd59iNY--HJ8B36YouVQKLeMCL8x+Ass7kw@mail.gmail.com>
Subject: Re: Interactivity regression since v3.11 in mm/vmscan.c
From: Felipe Contreras <felipe.contreras@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>

On Fri, Jun 6, 2014 at 6:03 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Fri 06-06-14 05:33:28, Felipe Contreras wrote:
>> On Fri, Jun 6, 2014 at 4:16 AM, Michal Hocko <mhocko@suse.cz> wrote:
>>
>> > Mel has a nice systemtap script (attached) to watch for stalls. Maybe
>> > you can give it a try?
>>
>> Is there any special configurations I should enable?
>
> You need debuginfo and systemtap AFAIK. I haven't used this script
> myself.

I have both.

-- 
Felipe Contreras

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

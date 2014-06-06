Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 0DB016B0035
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 08:27:09 -0400 (EDT)
Received: by mail-qg0-f54.google.com with SMTP id q108so4149052qgd.41
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 05:27:08 -0700 (PDT)
Received: from mail-qg0-x22f.google.com (mail-qg0-x22f.google.com [2607:f8b0:400d:c04::22f])
        by mx.google.com with ESMTPS id s49si12545062qgs.97.2014.06.06.05.27.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 06 Jun 2014 05:27:08 -0700 (PDT)
Received: by mail-qg0-f47.google.com with SMTP id j107so4184583qga.34
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 05:27:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140605133747.GB2942@dhcp22.suse.cz>
References: <53905594d284f_71f12992fc6a@nysa.notmuch>
	<20140605133747.GB2942@dhcp22.suse.cz>
Date: Fri, 6 Jun 2014 07:27:08 -0500
Message-ID: <CAMP44s2ExpR2OdvsiPVe9bdKdRYgsjEsXCfExTjQ_-eGMzvgKg@mail.gmail.com>
Subject: Re: Interactivity regression since v3.11 in mm/vmscan.c
From: Felipe Contreras <felipe.contreras@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>

On Thu, Jun 5, 2014 at 8:37 AM, Michal Hocko <mhocko@suse.cz> wrote:

> We had a similar report for opensuse. The common part was that there was
> an IO to a slow USB device going on.

Actually I've managed to narrow down my synthetic test, and all I need
is to copy a big file, and it even happens reading and writing to the
SSD (although the stall is less severe).

Here's the test:
http://pastie.org/9264124

Just pass a big file as the first argument.

I don't have much memory in this machine, so I guess running out of
memory is the trigger.

-- 
Felipe Contreras

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 908926B005C
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 11:56:26 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id n73GH66D013365
	for <linux-mm@kvack.org>; Mon, 3 Aug 2009 17:17:07 +0100
Received: from an-out-0708.google.com (anac3.prod.google.com [10.100.54.3])
	by wpaz13.hot.corp.google.com with ESMTP id n73GH3Ox028244
	for <linux-mm@kvack.org>; Mon, 3 Aug 2009 09:17:04 -0700
Received: by an-out-0708.google.com with SMTP id c3so1600100ana.17
        for <linux-mm@kvack.org>; Mon, 03 Aug 2009 09:17:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.0908011303050.22174@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.0907282125260.554@chino.kir.corp.google.com>
	 <alpine.DEB.2.00.0907300219580.13674@chino.kir.corp.google.com>
	 <20090730190216.5aae685a.kamezawa.hiroyu@jp.fujitsu.com>
	 <alpine.DEB.2.00.0907301157100.9652@chino.kir.corp.google.com>
	 <20090731093305.50bcc58d.kamezawa.hiroyu@jp.fujitsu.com>
	 <alpine.DEB.2.00.0907310231370.25447@chino.kir.corp.google.com>
	 <7f54310137837631f2526d4e335287fc.squirrel@webmail-b.css.fujitsu.com>
	 <alpine.DEB.2.00.0907311212240.22732@chino.kir.corp.google.com>
	 <77df8765230d9f83859fde3119a2d60a.squirrel@webmail-b.css.fujitsu.com>
	 <alpine.DEB.2.00.0908011303050.22174@chino.kir.corp.google.com>
Date: Mon, 3 Aug 2009 09:17:01 -0700
Message-ID: <6599ad830908030917v6c70ec01ke2ed15f0fb627f9@mail.gmail.com>
Subject: Re: [patch -mm v2] mm: introduce oom_adj_child
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 1, 2009 at 1:26 PM, David Rientjes<rientjes@google.com> wrote:
>
> It's more likely than not that applications were probably written to the
> way the documentation described the two files: that is, adjust
> /proc/pid/oom_score by tuning /proc/pid/oom_adj

I'd actually be pretty surprised if anyone was really doing that -
don't forget that the oom_score is something that varies dynamically
depending on things like the VM size of the process, its running time,
the VM sizes of its children, etc. So tuning oom_adj based on
oom_score will be rapidly out of date. AFAIK, oom_score was added
initially as a way to debug the OOM killer, and oom_adj was added
later as an additional knob. My suspicion is that any automated users
of oom_adj are working along the lines of

http://www.google.com/codesearch/p?hl=en&sa=N&cd=4&ct=rc#X7-oBZ_RyNM/src/server/memory/base/oommanager.cpp&q=oom_score

which just uses the values -16, 0 or 15, depending on whether the
process is critical, important or expendable.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

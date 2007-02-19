Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id l1J9oSQC025287
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 01:50:28 -0800
Received: from mu-out-0910.google.com (mufg7.prod.google.com [10.102.183.7])
	by zps37.corp.google.com with ESMTP id l1J9oNlP031089
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 01:50:24 -0800
Received: by mu-out-0910.google.com with SMTP id g7so429698muf
        for <linux-mm@kvack.org>; Mon, 19 Feb 2007 01:50:22 -0800 (PST)
Message-ID: <6599ad830702190150w254a8d4dncce45a1f9b369579@mail.gmail.com>
Date: Mon, 19 Feb 2007 01:50:22 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [ckrm-tech] [RFC][PATCH][0/4] Memory controller (RSS Control)
In-Reply-To: <45D972CC.2010702@sw.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070219065019.3626.33947.sendpatchset@balbir-laptop>
	 <20070219005441.7fa0eccc.akpm@linux-foundation.org>
	 <6599ad830702190106m3f391de4x170326fef2e4872@mail.gmail.com>
	 <45D972CC.2010702@sw.ru>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kirill Korotaev <dev@sw.ru>
Cc: Andrew Morton <akpm@linux-foundation.org>, vatsa@in.ibm.com, ckrm-tech@lists.sourceforge.net, Balbir Singh <balbir@in.ibm.com>, xemul@sw.ru, linux-kernel@vger.kernel.org, linux-mm@kvack.org, svaidy@linux.vnet.ibm.com, devel@openvz.org
List-ID: <linux-mm.kvack.org>

On 2/19/07, Kirill Korotaev <dev@sw.ru> wrote:
> >
> > I think it's OK for a container to consume lots of system time during
> > reclaim, as long as we can account that time to the container involved
> > (i.e. if it's done during direct reclaim rather than by something like
> > kswapd).
> hmm, is it ok to scan 100Gb of RAM for 10MB RAM container?
> in UBC patch set we used page beancounters to track containter pages.
> This allows to make efficient scan contoler and reclamation.

I don't mean that we shouldn't go for the most efficient method that's
practical. If we can do reclaim without spinning across so much of the
LRU, then that's obviously better.

But if the best approach in the general case results in a process in
the container spending lots of CPU time trying to do the reclaim,
that's probably OK as long as we can account for that time and (once
we have a CPU controller) throttle back the container in that case. So
then, a container can only hurt itself by thrashing/reclaiming, rather
than hurting other containers. (LRU churn notwithstanding ...)

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

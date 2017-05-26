Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id B5EE96B0292
	for <linux-mm@kvack.org>; Thu, 25 May 2017 23:24:49 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 64so2325343itb.1
        for <linux-mm@kvack.org>; Thu, 25 May 2017 20:24:49 -0700 (PDT)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id a203si611368itd.24.2017.05.25.20.24.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 May 2017 20:24:48 -0700 (PDT)
Date: Thu, 25 May 2017 22:24:46 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch 2/2] MM: allow per-cpu vmstat_threshold and vmstat_worker
 configuration
In-Reply-To: <20170525193508.GA30252@amt.cnet>
Message-ID: <alpine.DEB.2.20.1705252220130.7596@east.gentwo.org>
References: <alpine.DEB.2.20.1705121002310.22243@east.gentwo.org> <20170512154026.GA3556@amt.cnet> <alpine.DEB.2.20.1705121103120.22831@east.gentwo.org> <20170512161915.GA4185@amt.cnet> <alpine.DEB.2.20.1705121154240.23503@east.gentwo.org>
 <20170515191531.GA31483@amt.cnet> <alpine.DEB.2.20.1705160825480.32761@east.gentwo.org> <20170519143407.GA19282@amt.cnet> <alpine.DEB.2.20.1705191205580.19631@east.gentwo.org> <20170519134934.0c298882@redhat.com> <20170525193508.GA30252@amt.cnet>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Linux RT Users <linux-rt-users@vger.kernel.org>, cmetcalf@mellanox.com

On Thu, 25 May 2017, Marcelo Tosatti wrote:

> Argument? We're showing you the data that this is causing a latency
> problem for us.

Sorry I am not sure where the data shows a latency problem. There are
interrupts and scheduler ticks. But what does this have to do with vmstat?

Show me your dpdk code running and trace the tick on / off events  as well
as the vmstat invocations. Also show all system calls occurring on the cpu
that runs dpdk. That is necessary to see what triggers vmstat and how the
system reacts to the changes to the differentials.

Then please rerun the test by setting the vmstat_interval to 60.

Do another run with your modifications and show the difference.

> > Something that crossed my mind was to add a new tunable to set
> > the vmstat_interval for each CPU, this way we could essentially
> > disable it to the CPUs where DPDK is running. What's the implications
> > of doing this besides not getting up to date stats in /proc/vmstat
> > (which I still have to confirm would be OK)? Can this break anything
> > in the kernel for example?
>
> Well, you get incorrect statistics.

The statistics are never completely accurate. You will get less accurate
statistics but they will be correct. The differentials may not be
reflected in the counts shown via /proc but there is a cap on how
inaccurate those can becore.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

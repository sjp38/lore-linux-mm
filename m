Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id A87386B0038
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 15:36:46 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id m36so50947484qtb.16
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 12:36:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m47si10433278qtc.34.2017.04.25.12.36.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 12:36:45 -0700 (PDT)
Date: Tue, 25 Apr 2017 16:36:21 -0300
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [patch 2/2] MM: allow per-cpu vmstat_threshold and vmstat_worker
 configuration
Message-ID: <20170425193619.GA8403@amt.cnet>
References: <20170425135717.375295031@redhat.com>
 <20170425135846.203663532@redhat.com>
 <1493148546.31102.1.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1493148546.31102.1.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Luiz Capitulino <lcapitulino@redhat.com>, Linux RT Users <linux-rt-users@vger.kernel.org>

On Tue, Apr 25, 2017 at 03:29:06PM -0400, Rik van Riel wrote:
> On Tue, 2017-04-25 at 10:57 -0300, Marcelo Tosatti wrote:
> > The per-CPU vmstat worker is a problem on -RT workloads (because
> > ideally the CPU is entirely reserved for the -RT app, without
> > interference). The worker transfers accumulated per-CPU 
> > vmstat counters to global counters.
> > 
> > To resolve the problem, create two tunables:
> > 
> > * Userspace configurable per-CPU vmstat threshold: by default the 
> > VM code calculates the size of the per-CPU vmstat arrays. This 
> > tunable allows userspace to configure the values.
> > 
> > * Userspace configurable per-CPU vmstat worker: allow disabling
> > the per-CPU vmstat worker.
> > 
> > The patch below contains documentation which describes the tunables
> > in more detail.
> 
> The documentation says what the tunables do, but
> not how you should set them in different scenarios,
> or why.
> 
> That could be a little more helpful to sysadmins.

OK i'll update the document to be more verbose.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

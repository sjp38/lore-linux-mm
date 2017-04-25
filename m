Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 86AC06B0038
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 15:29:11 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id i18so51004826qte.1
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 12:29:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m65si23115115qkb.227.2017.04.25.12.29.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 12:29:10 -0700 (PDT)
Message-ID: <1493148546.31102.1.camel@redhat.com>
Subject: Re: [patch 2/2] MM: allow per-cpu vmstat_threshold and
 vmstat_worker configuration
From: Rik van Riel <riel@redhat.com>
Date: Tue, 25 Apr 2017 15:29:06 -0400
In-Reply-To: <20170425135846.203663532@redhat.com>
References: <20170425135717.375295031@redhat.com>
	 <20170425135846.203663532@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcelo Tosatti <mtosatti@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Luiz Capitulino <lcapitulino@redhat.com>, Linux RT Users <linux-rt-users@vger.kernel.org>

On Tue, 2017-04-25 at 10:57 -0300, Marcelo Tosatti wrote:
> The per-CPU vmstat worker is a problem on -RT workloads (because
> ideally the CPU is entirely reserved for the -RT app, without
> interference). The worker transfers accumulated per-CPUA 
> vmstat counters to global counters.
> 
> To resolve the problem, create two tunables:
> 
> * Userspace configurable per-CPU vmstat threshold: by default theA 
> VM code calculates the size of the per-CPU vmstat arrays. ThisA 
> tunable allows userspace to configure the values.
> 
> * Userspace configurable per-CPU vmstat worker: allow disabling
> the per-CPU vmstat worker.
> 
> The patch below contains documentation which describes the tunables
> in more detail.

The documentation says what the tunables do, but
not how you should set them in different scenarios,
or why.

That could be a little more helpful to sysadmins.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

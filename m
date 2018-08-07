Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 897346B026A
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 11:11:50 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id t14-v6so16215312ybb.0
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 08:11:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c185-v6sor334181ybb.113.2018.08.07.08.11.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Aug 2018 08:11:49 -0700 (PDT)
Date: Tue, 7 Aug 2018 08:11:46 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] proc: add percpu populated pages count to meminfo
Message-ID: <20180807151146.GB3978217@devbig004.ftw2.facebook.com>
References: <20180807005607.53950-1-dennisszhou@gmail.com>
 <0100016514bb069d-a6532c9a-b1ca-4eba-8644-c5b3935e3bd8-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0100016514bb069d-a6532c9a-b1ca-4eba-8644-c5b3935e3bd8-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Dennis Zhou <dennisszhou@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, kernel-team@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello,

On Tue, Aug 07, 2018 at 02:12:06PM +0000, Christopher Lameter wrote:
> > @@ -121,6 +122,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
> >  		   (unsigned long)VMALLOC_TOTAL >> 10);
> >  	show_val_kb(m, "VmallocUsed:    ", 0ul);
> >  	show_val_kb(m, "VmallocChunk:   ", 0ul);
> > +	show_val_kb(m, "PercpuPopulated:", pcpu_nr_populated_pages());
> 
> Populated? Can we avoid this for simplicities sake: "Percpu"?
> 
> We do not count pages that are not present elsewhere either and those
> counters do not have "populated" in them.

Yeah, let's do "Percpu".

Thanks.

-- 
tejun

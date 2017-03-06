Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 305FE6B0387
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 14:42:28 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id c85so254060617qkg.0
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 11:42:28 -0800 (PST)
Received: from mail-yw0-x22c.google.com (mail-yw0-x22c.google.com. [2607:f8b0:4002:c05::22c])
        by mx.google.com with ESMTPS id z2si2653179ywj.149.2017.03.06.11.42.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 11:42:27 -0800 (PST)
Received: by mail-yw0-x22c.google.com with SMTP id v76so30030946ywg.0
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 11:42:27 -0800 (PST)
Date: Mon, 6 Mar 2017 14:42:25 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH 2/2] mm/sparse: add last_section_nr in sparse_init()
 to reduce some iteration cycle
Message-ID: <20170306194225.GB19696@htj.duckdns.org>
References: <20170211021829.9646-1-richard.weiyang@gmail.com>
 <20170211021829.9646-2-richard.weiyang@gmail.com>
 <20170211022400.GA19050@mtj.duckdns.org>
 <CADZGycbxtoXXxCeg-nHjzGmHA72VnA=-td+hNaNqN67Vq2JuKg@mail.gmail.com>
 <CADZGycapTYxdxwHacFYiECZQ23uPDARQcahw_9zuKrNu-wG63g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADZGycapTYxdxwHacFYiECZQ23uPDARQcahw_9zuKrNu-wG63g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello, Wei.

On Fri, Feb 17, 2017 at 10:12:31PM +0800, Wei Yang wrote:
> > And compare the ruling with the iteration for the loop to be (1UL <<
> > 5) and (1UL << 19).
> > The runtime is 0.00s and 0.04s respectively. The absolute value is not much.

systemd-analyze usually does a pretty good job of breaking down which
phase took how long.  It might be worthwhile to test whether the
improvement is actually visible during the boot.

> >> * Do we really need to add full reverse iterator to just get the
> >>   highest section number?
> >>
> >
> > You are right. After I sent out the mail, I realized just highest pfn
> > is necessary.

That said, getting efficient is always great as long as the added
complexity is justifiably small enough.  If you can make the change
simple enough, it'd be a lot easier to merge.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

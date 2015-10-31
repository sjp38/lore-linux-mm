Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7F79782F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 21:15:20 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so92483004pac.3
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 18:15:20 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id zv5si14845803pac.189.2015.10.30.18.15.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Oct 2015 18:15:19 -0700 (PDT)
Received: by padhk11 with SMTP id hk11so88999352pad.1
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 18:15:19 -0700 (PDT)
Date: Sat, 31 Oct 2015 10:15:11 +0900
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [patch 3/3] vmstat: Create our own workqueue
Message-ID: <20151031011511.GE3582@mtj.duckdns.org>
References: <20151028024114.370693277@linux.com>
 <20151028024131.719968999@linux.com>
 <20151028024350.GA10448@mtj.duckdns.org>
 <alpine.DEB.2.20.1510272202120.4647@east.gentwo.org>
 <201510282057.JHI87536.OMOFFFLJOHQtVS@I-love.SAKURA.ne.jp>
 <20151029022447.GB27115@mtj.duckdns.org>
 <20151029030822.GD27115@mtj.duckdns.org>
 <alpine.DEB.2.20.1510292000340.30861@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1510292000340.30861@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de

On Thu, Oct 29, 2015 at 08:01:12PM -0500, Christoph Lameter wrote:
> On Thu, 29 Oct 2015, Tejun Heo wrote:
> 
> > Wait, this series doesn't include Tetsuo's change.  Of course it won't
> > fix the deadlock problem.  What's necessary is Tetsuo's patch +
> > WQ_MEM_RECLAIM.
> 
> This series is only dealing with vmstat changes. Do I get an ack here?

Yeap, please feel free to add my acked-by.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

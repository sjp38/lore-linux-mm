Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f174.google.com (mail-qc0-f174.google.com [209.85.216.174])
	by kanga.kvack.org (Postfix) with ESMTP id DEA956B0035
	for <linux-mm@kvack.org>; Sat, 29 Mar 2014 09:14:38 -0400 (EDT)
Received: by mail-qc0-f174.google.com with SMTP id c9so7037639qcz.19
        for <linux-mm@kvack.org>; Sat, 29 Mar 2014 06:14:38 -0700 (PDT)
Received: from mail-qg0-x232.google.com (mail-qg0-x232.google.com [2607:f8b0:400d:c04::232])
        by mx.google.com with ESMTPS id b6si3838397qae.145.2014.03.29.06.14.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 29 Mar 2014 06:14:38 -0700 (PDT)
Received: by mail-qg0-f50.google.com with SMTP id q108so5496845qgd.37
        for <linux-mm@kvack.org>; Sat, 29 Mar 2014 06:14:38 -0700 (PDT)
Date: Sat, 29 Mar 2014 09:14:34 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] mm/percpu.c: don't bother to re-walk the pcpu_slot
 list if nobody free space since we last drop pcpu_lock
Message-ID: <20140329131434.GB5553@htj.dyndns.org>
References: <1396011357-21560-1-git-send-email-nasa4836@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1396011357-21560-1-git-send-email-nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, cl@linux-foundation.org, linux-kernel@vger.kernel.org

On Fri, Mar 28, 2014 at 08:55:57PM +0800, Jianyu Zhan wrote:
> Quoted tj: 
> >Hmmm... I'm not sure whether the added complexity is worthwhile.  It's
> >a fairly cold path.  Can you show how helpful this optimization is?
> 
> The patch is quite less intrusive in the normal path
> and if we fall on the cold path, it means after satifying this allocation 
> the chunk may be moved to lower slot, and the follow-up allocation 
> of same or larger size(though rare) is likely to fail to cold path again. So
> this patch could be based on to do some heuristic later.

The above really doesn't show how helpful it is.  This adds complexity
to optimize what seemingly is a quite cold path, which often is a
pretty bad idea as they tend to trade off readability and long term
maintainability for almost non-existing actual gain.  If you think
this is a worthwhile optimization, please give justifications - use
scenarios, performance numbers and so on.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EA1BF6B0069
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 20:24:45 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id t25so94084941pfg.3
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 17:24:45 -0700 (PDT)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id z4si12920403pgb.66.2016.10.13.17.24.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 17:24:45 -0700 (PDT)
Received: by mail-pf0-x235.google.com with SMTP id 128so42026493pfz.0
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 17:24:45 -0700 (PDT)
Date: Thu, 13 Oct 2016 20:24:41 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC v2 PATCH] mm/percpu.c: fix panic triggered by BUG_ON()
 falsely
Message-ID: <20161014002441.GG32534@mtj.duckdns.org>
References: <57FCF07C.2020103@zoho.com>
 <20161013232902.GD32534@mtj.duckdns.org>
 <92d3e474-856a-7f78-a9c3-b83e5913cd13@zoho.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <92d3e474-856a-7f78-a9c3-b83e5913cd13@zoho.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zijun_hu <zijun_hu@zoho.com>
Cc: zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, cl@linux.com

Hello,

On Fri, Oct 14, 2016 at 08:06:10AM +0800, zijun_hu wrote:
> > I really can't decode what the actual issue is here.  Can you please
> > give an example of a concrete case?
> > 
> the right relationship between the number of CPUs @nr_cpus within a percpu group
> and the number of unites @nr_units within the same group is that
> @nr_units == roundup(@nr_cpus, @upa);

My question was whether there can be actual hardware configurations
where this code can fail and if so what they look like and how they
would fail.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

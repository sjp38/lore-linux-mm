Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 517FC680F7F
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 19:20:59 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id uo6so312592218pac.1
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 16:20:59 -0800 (PST)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id vt4si22518417pab.8.2016.01.11.16.20.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 16:20:58 -0800 (PST)
Received: by mail-pa0-x230.google.com with SMTP id ho8so68556348pac.2
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 16:20:58 -0800 (PST)
Date: Mon, 11 Jan 2016 16:20:56 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: add ratio in slabinfo print
In-Reply-To: <5693AAD5.6090101@huawei.com>
Message-ID: <alpine.DEB.2.10.1601111619120.5824@chino.kir.corp.google.com>
References: <56932791.3080502@huawei.com> <20160111122553.GB27317@dhcp22.suse.cz> <5693AAD5.6090101@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Michal Hocko <mhocko@kernel.org>, cl@linux.com, Pekka Enberg <penberg@kernel.org>, iamjoonsoo.kim@lge.com, Andrew Morton <akpm@linux-foundation.org>, zhong jiang <zhongjiang@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 11 Jan 2016, Xishi Qiu wrote:

> > On Mon 11-01-16 11:54:57, Xishi Qiu wrote:
> >> Add ratio(active_objs/num_objs) in /proc/slabinfo, it is used to show
> >> the availability factor in each slab.
> > 
> > What is the reason to add such a new value when it can be trivially
> > calculated from the userspace?
> > 
> > Besides that such a change would break existing parsers no?
> 
> Oh, maybe it is.
> 

If you need the information internally, you could always create a library 
around slabinfo and export the information for users who are interested 
for your own use.  Doing anything other than appending fields to each line 
is too dangerous, however, as a general rule.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

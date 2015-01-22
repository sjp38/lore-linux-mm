Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id CF5F26B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 11:14:50 -0500 (EST)
Received: by mail-qc0-f172.google.com with SMTP id i8so1972614qcq.3
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 08:14:50 -0800 (PST)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id k95si5027012qgd.72.2015.01.22.08.14.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 22 Jan 2015 08:14:50 -0800 (PST)
Date: Thu, 22 Jan 2015 10:14:48 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mmotm: mm-slub-optimize-alloc-free-fastpath-by-removing-preemption-on-off.patch
 is causing preemptible splats
In-Reply-To: <20150121132308.GB23700@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.11.1501221014110.3937@gentwo.org>
References: <20150121132308.GB23700@dhcp22.suse.cz>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>


> I am not sure how to fix this but it sounds like this_cpu_ptr should
> offer the same preempt expectations as other this_cpu_* functions.

One returns a pointer that may not be useful if the context is switched
and the other completes a operationo on an opject.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

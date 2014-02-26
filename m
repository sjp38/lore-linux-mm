Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 6D0A26B009F
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 02:05:07 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id va2so363713obc.34
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 23:05:07 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id o4si19143163oei.98.2014.02.25.23.05.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 25 Feb 2014 23:05:02 -0800 (PST)
Message-ID: <530D9216.8050808@oracle.com>
Date: Wed, 26 Feb 2014 15:04:54 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [LSF/MM ATTEND] slab cache extension -- slab cache in fixed size
References: <52D662A4.1080502@oracle.com> <alpine.DEB.2.10.1401310941430.6849@nuc> <530C0F08.1040000@oracle.com> <alpine.DEB.2.10.1402251225280.30822@nuc>
In-Reply-To: <alpine.DEB.2.10.1402251225280.30822@nuc>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>


On 02/26 2014 02:26 AM, Christoph Lameter wrote:
> On Tue, 25 Feb 2014, Jeff Liu wrote:
> 
>> In this case, another thing I'm hesitating about whether to export the cache_limit
>> via /proc/slabinfo by extending its tunable fields -- the per-CPU slab cache limit
>> and batchcount, as thus will change the user space interface and slabtop(1) need to
>> be modified accordingly.
> 
> Can you move the code to handle /sys/kernel/slab into mm/slab_common.c and
> then make slab use that? (Maybe a bit of a tough call but that has to be
> done at some point).

Yes, so that we can enabled those debug functions for both slab and slub, thanks for
your direction. :)

> 
> Once you got a directly with settings per slab then its trivial to add
> another field.

Indeed, that would be convenient afterwards.


Thanks,
-Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

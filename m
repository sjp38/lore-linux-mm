Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 91FF16B0285
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 04:13:20 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id r6so10670686obx.1
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 01:13:20 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0102.outbound.protection.outlook.com. [104.47.0.102])
        by mx.google.com with ESMTPS id 30si13842102oti.234.2016.06.14.01.13.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 14 Jun 2016 01:13:19 -0700 (PDT)
Date: Tue, 14 Jun 2016 11:13:12 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH RFC] slub: reap free slabs periodically
Message-ID: <20160614081312.GL30465@esperanza>
References: <1465575243-18882-1-git-send-email-vdavydov@virtuozzo.com>
 <alpine.DEB.2.20.1606101629520.6786@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1606101629520.6786@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 10, 2016 at 04:32:26PM -0500, Christoph Lameter wrote:
> One reason for SLUBs creation was the 2 second scans in  SLAB which causes
> significant disruption of latency sensitive tasksk.

That's not good, indeed.

> 
> You can simply implement a reaper in userspace by running
> 
> slabinfo -s
> 
> if you have to have this.

Doing this periodically would probably hurt performance of active caches
as 'slabinfo -s' shrinks all slabs unconditionally, even if they are
being actively used. OTOH, one could trigger shrinking slabs only on
memory pressure. That would require yet another daemon tracking the
system state, but it is doable I guess.

Thanks a lot for your input, Christoph.

> 
> There is no need to duplicate SLAB problems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

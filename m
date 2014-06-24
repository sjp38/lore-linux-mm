Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f50.google.com (mail-qa0-f50.google.com [209.85.216.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5C1896B0039
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 16:58:35 -0400 (EDT)
Received: by mail-qa0-f50.google.com with SMTP id m5so749071qaj.37
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 13:58:35 -0700 (PDT)
Received: from mail-qc0-x22a.google.com (mail-qc0-x22a.google.com [2607:f8b0:400d:c01::22a])
        by mx.google.com with ESMTPS id l10si1911665qad.51.2014.06.24.13.58.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 24 Jun 2014 13:58:34 -0700 (PDT)
Received: by mail-qc0-f170.google.com with SMTP id l6so875014qcy.15
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 13:58:34 -0700 (PDT)
Date: Tue, 24 Jun 2014 16:58:32 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm/mempolicy: fix sleeping function called from invalid
 context
Message-ID: <20140624205832.GB14909@htj.dyndns.org>
References: <53902A44.50005@cn.fujitsu.com>
 <20140605132339.ddf6df4a0cf5c14d17eb8691@linux-foundation.org>
 <539192F1.7050308@cn.fujitsu.com>
 <alpine.DEB.2.02.1406081539140.21744@chino.kir.corp.google.com>
 <539574F1.2060701@cn.fujitsu.com>
 <alpine.DEB.2.02.1406090209460.24247@chino.kir.corp.google.com>
 <53967465.7070908@huawei.com>
 <20140620210137.GA2059@mtj.dyndns.org>
 <53A8E23C.4050103@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53A8E23C.4050103@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: David Rientjes <rientjes@google.com>, Gu Zheng <guz.fnst@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Cgroups <cgroups@vger.kernel.org>, stable@vger.kernel.org

Hello,

On Tue, Jun 24, 2014 at 10:28:12AM +0800, Li Zefan wrote:
> > I don't think the suggested patch breaks anything more than it was
> > broken before and we should probably apply it for the time being.  Li?
> 
> Yeah, we should apply Gu Zheng's patch any way.

Gu Zheng, can you please respin the patch with updated explanation on
the temporary nature of the change.  I'll apply it once Li acks it.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

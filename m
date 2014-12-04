Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f44.google.com (mail-yh0-f44.google.com [209.85.213.44])
	by kanga.kvack.org (Postfix) with ESMTP id E6A956B0085
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 16:19:16 -0500 (EST)
Received: by mail-yh0-f44.google.com with SMTP id c41so8613921yho.31
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 13:19:16 -0800 (PST)
Received: from mail-qa0-x234.google.com (mail-qa0-x234.google.com. [2607:f8b0:400d:c00::234])
        by mx.google.com with ESMTPS id gt10si19155149qcb.1.2014.12.04.13.19.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 04 Dec 2014 13:19:16 -0800 (PST)
Received: by mail-qa0-f52.google.com with SMTP id dc16so12697530qab.11
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 13:19:15 -0800 (PST)
Date: Thu, 4 Dec 2014 16:19:12 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC v2] percpu: Add a separate function to merge free areas
Message-ID: <20141204211912.GG4080@htj.dyndns.org>
References: <547E3E57.3040908@ixiacom.com>
 <20141204175713.GE2995@htj.dyndns.org>
 <5480BFAA.2020106@ixiacom.com>
 <alpine.DEB.2.11.1412041426230.14577@gentwo.org>
 <20141204205202.GP29748@ZenIV.linux.org.uk>
 <alpine.DEB.2.11.1412041514250.14832@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1412041514250.14832@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Leonard Crestez <lcrestez@ixiacom.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sorin Dumitru <sdumitru@ixiacom.com>

On Thu, Dec 04, 2014 at 03:15:27PM -0600, Christoph Lameter wrote:
> On Thu, 4 Dec 2014, Al Viro wrote:
> 
> > ... except that somebody has not known that and took refcounts on e.g.
> > vfsmounts into percpu.  With massive amounts of hilarity once docker folks
> > started to test the workloads that created/destroyed those in large amounts.
> 
> Well, vfsmounts being a performance issue is a bit weird and unexpected.

Docker usage is pretty wide-spread now, making what used to be
siberia-cold paths hot enough to cause actual scalability issues.
Besides, we're now using percpu_ref for things like aio and cgroup
control structures which can be created and destroyed quite
frequently.  I don't think we can say these are "weird" use cases
anymore.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

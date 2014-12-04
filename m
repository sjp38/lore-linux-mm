Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 082986B0082
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 16:15:31 -0500 (EST)
Received: by mail-ig0-f173.google.com with SMTP id r2so19469357igi.0
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 13:15:30 -0800 (PST)
Received: from resqmta-po-08v.sys.comcast.net (resqmta-po-08v.sys.comcast.net. [2001:558:fe16:19:96:114:154:167])
        by mx.google.com with ESMTPS id t8si18833884ioi.6.2014.12.04.13.15.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 04 Dec 2014 13:15:30 -0800 (PST)
Date: Thu, 4 Dec 2014 15:15:27 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC v2] percpu: Add a separate function to merge free areas
In-Reply-To: <20141204205202.GP29748@ZenIV.linux.org.uk>
Message-ID: <alpine.DEB.2.11.1412041514250.14832@gentwo.org>
References: <547E3E57.3040908@ixiacom.com> <20141204175713.GE2995@htj.dyndns.org> <5480BFAA.2020106@ixiacom.com> <alpine.DEB.2.11.1412041426230.14577@gentwo.org> <20141204205202.GP29748@ZenIV.linux.org.uk>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Leonard Crestez <lcrestez@ixiacom.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sorin Dumitru <sdumitru@ixiacom.com>

On Thu, 4 Dec 2014, Al Viro wrote:

> ... except that somebody has not known that and took refcounts on e.g.
> vfsmounts into percpu.  With massive amounts of hilarity once docker folks
> started to test the workloads that created/destroyed those in large amounts.

Well, vfsmounts being a performance issue is a bit weird and unexpected.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

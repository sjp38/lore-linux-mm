Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6DF066B0038
	for <linux-mm@kvack.org>; Thu, 28 Aug 2014 11:31:41 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id hz1so2957337pad.6
        for <linux-mm@kvack.org>; Thu, 28 Aug 2014 08:31:39 -0700 (PDT)
Received: from qmta02.emeryville.ca.mail.comcast.net (qmta02.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:24])
        by mx.google.com with ESMTPS id fa16si7180216pac.82.2014.08.28.08.31.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 28 Aug 2014 08:31:29 -0700 (PDT)
Date: Thu, 28 Aug 2014 10:31:26 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: mm: slub: circular dependency between slab_mutex and
 cpu_hotplug
In-Reply-To: <53FF4280.1040402@oracle.com>
Message-ID: <alpine.DEB.2.11.1408281030510.6401@gentwo.org>
References: <53FF4280.1040402@oracle.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "davej @gmail-imap.l.google.com>> Dave Jones" <davej@redhat.com>

On Thu, 28 Aug 2014, Sasha Levin wrote:

> While fuzzing with trinity inside a KVM tools guest running the latest -next
> kernel, I've stumbled on the following spew:

This looks to me more to be a cpu hotplug issue.
>
> [ 7841.323177]  Possible unsafe locking scenario:
> [ 7841.323177]
> [ 7841.323177]        CPU0                    CPU1
> [ 7841.323177]        ----                    ----
> [ 7841.323177]   lock(cpu_hotplug.lock#2);
> [ 7841.323177]                                lock((oom_notify_list).rwsem);
> [ 7841.323177]                                lock(cpu_hotplug.lock#2);
> [ 7841.323177]   lock(slab_mutex);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

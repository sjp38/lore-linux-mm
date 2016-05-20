Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f198.google.com (mail-ig0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id DA1776B0005
	for <linux-mm@kvack.org>; Thu, 19 May 2016 22:15:59 -0400 (EDT)
Received: by mail-ig0-f198.google.com with SMTP id sq19so191290319igc.0
        for <linux-mm@kvack.org>; Thu, 19 May 2016 19:15:59 -0700 (PDT)
Received: from mail-oi0-x243.google.com (mail-oi0-x243.google.com. [2607:f8b0:4003:c06::243])
        by mx.google.com with ESMTPS id f9si8539095oeo.45.2016.05.19.19.15.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 May 2016 19:15:59 -0700 (PDT)
Received: by mail-oi0-x243.google.com with SMTP id w198so20565949oiw.2
        for <linux-mm@kvack.org>; Thu, 19 May 2016 19:15:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJcbSZGUTJdzRDno=+V+F4Yu_gaU_k0UJq5xhF5PPwgKGi3O7A@mail.gmail.com>
References: <1463594175-111929-1-git-send-email-thgarnie@google.com>
	<1463594175-111929-3-git-send-email-thgarnie@google.com>
	<alpine.DEB.2.20.1605181323260.14349@east.gentwo.org>
	<CAJcbSZFhsZheqdZ5FD8auhiu8ozCyq-0xY1wjYu3j+Wc2R8nGg@mail.gmail.com>
	<alpine.DEB.2.20.1605181401560.29313@east.gentwo.org>
	<CAJcbSZHwZxH=NN+xk7N+O-47QQHmRchgqMS5==_HzH1no5ho9g@mail.gmail.com>
	<20160519020722.GC10245@js1304-P5Q-DELUXE>
	<CAJcbSZGUTJdzRDno=+V+F4Yu_gaU_k0UJq5xhF5PPwgKGi3O7A@mail.gmail.com>
Date: Fri, 20 May 2016 11:15:58 +0900
Message-ID: <CAAmzW4PN4wcPWbjf=Hws2qN_eZC1HCmn-gQC9_DB5ek5+bNksQ@mail.gmail.com>
Subject: Re: [RFC v1 2/2] mm: SLUB Freelist randomization
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Pranith Kumar <bobby.prani@gmail.com>, David Howells <dhowells@redhat.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, David Woodhouse <David.Woodhouse@intel.com>, Petr Mladek <pmladek@suse.com>, Kees Cook <keescook@chromium.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Greg Thelen <gthelen@google.com>, kernel-hardening@lists.openwall.com

2016-05-20 5:20 GMT+09:00 Thomas Garnier <thgarnie@google.com>:
> I ran the test given by Joonsoo and it gave me these minimum cycles
> per size across 20 usage:

I can't understand what you did here. Maybe, it's due to my poor Engling.
Please explain more. You did single thread test? Why minimum cycles
rather than average?

> size,before,after
> 8,63.00,64.50 (102.38%)
> 16,64.50,65.00 (100.78%)
> 32,65.00,65.00 (100.00%)
> 64,66.00,65.00 (98.48%)
> 128,66.00,65.00 (98.48%)
> 256,64.00,64.00 (100.00%)
> 512,65.00,66.00 (101.54%)
> 1024,68.00,64.00 (94.12%)
> 2048,66.00,65.00 (98.48%)
> 4096,66.00,66.00 (100.00%)

It looks like performance of all size classes are the same?

> I assume the difference is bigger if you don't have RDRAND support.

What does RDRAND means? Kconfig? How can I check if I have RDRAND?

> Christoph, Joonsoo: Do you think it would be valuable to add a CONFIG
> to disable additional randomization per new page? It will remove
> additional entropy but increase performance for machines without arch
> specific randomization instructions.

I don't think that it deserve another CONFIG. If performance is a matter,
I think that removing additional entropy is better until it is proved that
entropy is a problem.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 8FCED6B0038
	for <linux-mm@kvack.org>; Sat, 11 Apr 2015 03:25:50 -0400 (EDT)
Received: by qkhg7 with SMTP id g7so67238691qkh.2
        for <linux-mm@kvack.org>; Sat, 11 Apr 2015 00:25:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 70si4159356qgb.16.2015.04.11.00.25.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 11 Apr 2015 00:25:49 -0700 (PDT)
Date: Sat, 11 Apr 2015 09:25:43 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: slub bulk alloc: Extract objects from the per cpu slab
Message-ID: <20150411092543.6c1b395d@redhat.com>
In-Reply-To: <alpine.DEB.2.11.1504102115320.1179@gentwo.org>
References: <alpine.DEB.2.11.1504081311070.20469@gentwo.org>
	<20150408155304.4480f11f16b60f09879c350d@linux-foundation.org>
	<alpine.DEB.2.11.1504090859560.19278@gentwo.org>
	<20150409131916.51a533219dbff7a6f2294034@linux-foundation.org>
	<alpine.DEB.2.11.1504102115320.1179@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, brouer@redhat.com


On Fri, 10 Apr 2015 21:19:06 -0500 (CDT) Christoph Lameter <cl@linux.com> wrote:
> On Thu, 9 Apr 2015, Andrew Morton wrote:
> 
[...]
> > Keeping them in -next is not a problem - I was wondering about when to
> > start moving the code into mainline.
> 
> When Mr. Brouer has confirmed that the stuff actually does some good for
> his issue.

I plan to pickup working on this from Monday. (As Christoph already
knows, I've just moved back to Denmark from New Zealand.)

I'll start with micro benchmarking, to make sure bulk-alloc is faster
than normal-alloc.  Once we/I have some framework, we can easier
compare the different optimizations that Christoph is planning.

The interesting step for me is using this in the networking stack.

For real use-cases, like IP-forwarding, my experience tells me that the
added code size can easily reduce the performance gain, because
of more instruction-cache misses.  Fortunately bulk-alloc is call
less-times, which amortize these icache-misses, but still something we
need to be aware of as it will not show-up in micro benchmarking.

ps. Thanks for the work guys! :-)
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

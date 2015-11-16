Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id D6F806B0254
	for <linux-mm@kvack.org>; Mon, 16 Nov 2015 09:24:45 -0500 (EST)
Received: by ykfs79 with SMTP id s79so241356953ykf.1
        for <linux-mm@kvack.org>; Mon, 16 Nov 2015 06:24:45 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l139si23392366ywb.93.2015.11.16.06.24.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Nov 2015 06:24:45 -0800 (PST)
Date: Mon, 16 Nov 2015 15:24:40 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: Memory exhaustion testing?
Message-ID: <20151116152440.101ea77d@redhat.com>
In-Reply-To: <alpine.DEB.2.10.1511131452130.6173@chino.kir.corp.google.com>
References: <20151112215531.69ccec19@redhat.com>
	<alpine.DEB.2.10.1511131452130.6173@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm <linux-mm@kvack.org>, brouer@redhat.com, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>


On Fri, 13 Nov 2015 14:54:37 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> [...]  This is why 
> failslab had been used in the past, and does a good job at runtime 
> testing.  

Thanks for mentioning CONFIG_FAILSLAB.  First I disregarded
"failslab" (I did notice it in the slub code) because it didn't
exercised the code path I wanted in kmem_cache_alloc_bulk().

But went to looking up the config setting I notice that we do have a
hole section for "Fault-injection".  Which is great, and what I was
looking for.

Menu config Location:
 -> Kernel hacking
  -> Fault-injection framework (FAULT_INJECTION [=y])

I think what I need can be covered by FAIL_PAGE_ALLOC, or should_fail_alloc_page().
I'll try and play a bit with it...

- - 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

[*] Fault-injection framework
[*]   Fault-injection capability for kmalloc
[*]   Fault-injection capabilitiy for alloc_pages()
[ ]   Fault-injection capability for disk IO
[ ]   Fault-injection capability for faking disk interrupts
[ ]   Fault-injection capability for futexes
[*]   Debugfs entries for fault-injection capabilities

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

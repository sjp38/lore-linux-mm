Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id CFB846B0044
	for <linux-mm@kvack.org>; Thu, 14 Nov 2013 05:12:50 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id lf10so1873040pab.22
        for <linux-mm@kvack.org>; Thu, 14 Nov 2013 02:12:50 -0800 (PST)
Received: from psmtp.com ([74.125.245.170])
        by mx.google.com with SMTP id n5si27441226pav.185.2013.11.14.02.12.48
        for <linux-mm@kvack.org>;
        Thu, 14 Nov 2013 02:12:49 -0800 (PST)
Received: by mail-pd0-f174.google.com with SMTP id y10so1780637pdj.33
        for <linux-mm@kvack.org>; Thu, 14 Nov 2013 02:12:47 -0800 (PST)
Date: Thu, 14 Nov 2013 02:12:45 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Unnecessary mass OOM kills on Linux 3.11 virtualization host
In-Reply-To: <52849CD2.4030406@elastichosts.com>
Message-ID: <alpine.DEB.2.02.1311140211560.16862@chino.kir.corp.google.com>
References: <20131024224326.GA19654@alpha.arachsys.com> <20131025103946.GA30649@alpha.arachsys.com> <20131028082825.GA30504@alpha.arachsys.com> <52836002.5050901@elastichosts.com> <20131113120948.GE2834@moon> <52837216.1090100@elastichosts.com>
 <20131113131921.GF2834@moon> <52849CD2.4030406@elastichosts.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alin Dobre <alin.dobre@elastichosts.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org

On Thu, 14 Nov 2013, Alin Dobre wrote:

> Thanks Cyrill! We'll test the kernel anyway to try and reproduce the mass oom
> killing, so we'll see from there.
> 

If you're able to reproduce it, please ensure /proc/sys/vm/oom_dump_tasks 
is set to 1 and provide the full kernel log.  It makes debugging things 
like this much easier.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

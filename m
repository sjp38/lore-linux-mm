Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 366616B0044
	for <linux-mm@kvack.org>; Thu, 14 Nov 2013 05:15:31 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id y13so1788159pdi.27
        for <linux-mm@kvack.org>; Thu, 14 Nov 2013 02:15:30 -0800 (PST)
Received: from psmtp.com ([74.125.245.199])
        by mx.google.com with SMTP id yk3si27480686pac.12.2013.11.14.02.15.25
        for <linux-mm@kvack.org>;
        Thu, 14 Nov 2013 02:15:26 -0800 (PST)
Message-ID: <5284A2A0.4060008@elastichosts.com>
Date: Thu, 14 Nov 2013 10:14:56 +0000
From: Alin Dobre <alin.dobre@elastichosts.com>
MIME-Version: 1.0
Subject: Re: Unnecessary mass OOM kills on Linux 3.11 virtualization host
References: <20131024224326.GA19654@alpha.arachsys.com> <20131025103946.GA30649@alpha.arachsys.com> <20131028082825.GA30504@alpha.arachsys.com> <52836002.5050901@elastichosts.com> <20131113120948.GE2834@moon> <52837216.1090100@elastichosts.com> <20131113131921.GF2834@moon> <52849CD2.4030406@elastichosts.com> <alpine.DEB.2.02.1311140211560.16862@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1311140211560.16862@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org

On 14/11/13 10:12, David Rientjes wrote:
> On Thu, 14 Nov 2013, Alin Dobre wrote:
>
>> Thanks Cyrill! We'll test the kernel anyway to try and reproduce the mass oom
>> killing, so we'll see from there.
>>
>
> If you're able to reproduce it, please ensure /proc/sys/vm/oom_dump_tasks
> is set to 1 and provide the full kernel log.  It makes debugging things
> like this much easier.
>

It's already enabled, thanks for the tip.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

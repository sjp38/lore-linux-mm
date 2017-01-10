Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 879B46B025E
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 10:35:59 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id y196so126717917ity.1
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 07:35:59 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id a36si2510205pli.2.2017.01.10.07.35.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jan 2017 07:35:58 -0800 (PST)
Subject: Re: Benchmarks for the Linux kernel MM architecture
References: <20170106222912.o6vkh7rarxdak4ga@arch-test>
From: David Nellans <dnellans@nvidia.com>
Message-ID: <4f430912-d506-3904-c073-e1e121c3fc70@nvidia.com>
Date: Tue, 10 Jan 2017 09:35:56 -0600
MIME-Version: 1.0
In-Reply-To: <20170106222912.o6vkh7rarxdak4ga@arch-test>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Till Smejkal <till.smejkal@hpe.com>, linux-mm@kvack.org



On 01/06/2017 04:29 PM, Till Smejkal wrote:
> Dear Linux MM community
>
> My name is Till Smejkal and I am a PhD Student at Hewlett Packard Enterprise. For a
> couple of weeks I have been working on a patchset for the Linux kernel which
> introduces a new functionality that allows address spaces to be first class citizens
> in the OS. The implementation is based on a concept presented in this [1] paper.
>
> The basic idea of the patchset is that an AS not necessarily needs to be coupled with
> a process but can be created and destroyed independently. A process still has its own
> AS which is created with the process and which also gets destroyed with the process,
> but in addition there can be other AS in the OS which are not bound to the lifetime
> of any process. These additional AS have to be created and destroyed actively by the
> user and can be attached to a process as additional AS. Attaching such an AS to a
> process allows the process to have different views on the memory between which the
> process can switch arbitrarily during its executing.
>
> This feature can be used in various different ways. For example to compartmentalize a
> process for security reasons or to improve the performance of data-centric
> applications.
>
> However, before I intend to submit the patchset to LKML, I first like to perform
> some benchmarks to identify possible performance drawbacks introduced by my changes
> to the original memory management architecture. Hence, I would like to ask if anyone
> of you could point me to some benchmarks which I can run to test my patchset and
> compare it against the original implementation.
>
> If there are any questions, please feel free to ask me. I am happy to answer any
> question related to the patchset and its idea/intention.
>
> Regards
> Till
>
> P.S.: Please keep me in the CC since I am not subscribed to this mailing list.
>
> [1] http://impact.crhc.illinois.edu/shared/Papers/ASPLOS16-SpaceJMP.pdf

https://github.com/gormanm/mmtests

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

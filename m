Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id CA4C36B0033
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 22:23:20 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id f144so244900408pfa.3
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 19:23:20 -0800 (PST)
Received: from out4434.biz.mail.alibaba.com (out4434.biz.mail.alibaba.com. [47.88.44.34])
        by mx.google.com with ESMTP id w4si4233587pfi.279.2017.01.10.19.23.18
        for <linux-mm@kvack.org>;
        Tue, 10 Jan 2017 19:23:19 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170106222912.o6vkh7rarxdak4ga@arch-test> <4f430912-d506-3904-c073-e1e121c3fc70@nvidia.com>
In-Reply-To: <4f430912-d506-3904-c073-e1e121c3fc70@nvidia.com>
Subject: Re: Benchmarks for the Linux kernel MM architecture
Date: Wed, 11 Jan 2017 11:10:10 +0800
Message-ID: <01f601d26bb8$380bfd30$a823f790$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'David Nellans' <dnellans@nvidia.com>, 'Till Smejkal' <till.smejkal@hpe.com>, linux-mm@kvack.org


On Tuesday, January 10, 2017 11:36 PM David Nellans wrote: 
> 
> On 01/06/2017 04:29 PM, Till Smejkal wrote:
> > Dear Linux MM community
> >
> > My name is Till Smejkal and I am a PhD Student at Hewlett Packard Enterprise. For a
> > couple of weeks I have been working on a patchset for the Linux kernel which
> > introduces a new functionality that allows address spaces to be first class citizens
> > in the OS. The implementation is based on a concept presented in this [1] paper.
> >
> > The basic idea of the patchset is that an AS not necessarily needs to be coupled with
> > a process but can be created and destroyed independently. A process still has its own
> > AS which is created with the process and which also gets destroyed with the process,
> > but in addition there can be other AS in the OS which are not bound to the lifetime
> > of any process. These additional AS have to be created and destroyed actively by the
> > user and can be attached to a process as additional AS. Attaching such an AS to a
> > process allows the process to have different views on the memory between which the
> > process can switch arbitrarily during its executing.
> >
> > This feature can be used in various different ways. For example to compartmentalize a
> > process for security reasons or to improve the performance of data-centric
> > applications.
> >
> > However, before I intend to submit the patchset to LKML, I first like to perform
> > some benchmarks to identify possible performance drawbacks introduced by my changes
> > to the original memory management architecture. Hence, I would like to ask if anyone
> > of you could point me to some benchmarks which I can run to test my patchset and
> > compare it against the original implementation.
> >
> > If there are any questions, please feel free to ask me. I am happy to answer any
> > question related to the patchset and its idea/intention.
> >
> > Regards
> > Till
> >
> > P.S.: Please keep me in the CC since I am not subscribed to this mailing list.
> >
> > [1] http://impact.crhc.illinois.edu/shared/Papers/ASPLOS16-SpaceJMP.pdf
> 
> https://github.com/gormanm/mmtests
> 
And please take a look at linux-4.9/tools/testing/selftests/vm. 

The last resort seems to ask Mel on linux-mm for 
howtos he knows.
	Mel Gorman <mgorman@techsingularity.net>

Good luck
Hillf


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

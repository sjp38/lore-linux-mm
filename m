Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id C859D6B0253
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 18:28:00 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id m98so164594248iod.2
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 15:28:00 -0800 (PST)
Received: from g9t5009.houston.hpe.com (g9t5009.houston.hpe.com. [15.241.48.73])
        by mx.google.com with ESMTPS id c129si10083530ita.83.2017.01.23.15.28.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 15:28:00 -0800 (PST)
Date: Mon, 23 Jan 2017 15:27:58 -0800
From: Till Smejkal <till.smejkal@hpe.com>
Subject: Re: Benchmarks for the Linux kernel MM architecture
Message-ID: <20170123232758.lfxhffirokxpx62g@arch-dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01f601d26bb8$380bfd30$a823f790$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'David Nellans' <dnellans@nvidia.com>, linux-mm@kvack.org

On Wed, 11 Jan 2017, Hillf Danton wrote:
> 
> On Tuesday, January 10, 2017 11:36 PM David Nellans wrote: 
> > 
> > On 01/06/2017 04:29 PM, Till Smejkal wrote:
> > > Dear Linux MM community
> > >
> > > My name is Till Smejkal and I am a PhD Student at Hewlett Packard Enterprise. For a
> > > couple of weeks I have been working on a patchset for the Linux kernel which
> > > introduces a new functionality that allows address spaces to be first class citizens
> > > in the OS. The implementation is based on a concept presented in this [1] paper.
> > >
> > > The basic idea of the patchset is that an AS not necessarily needs to be coupled with
> > > a process but can be created and destroyed independently. A process still has its own
> > > AS which is created with the process and which also gets destroyed with the process,
> > > but in addition there can be other AS in the OS which are not bound to the lifetime
> > > of any process. These additional AS have to be created and destroyed actively by the
> > > user and can be attached to a process as additional AS. Attaching such an AS to a
> > > process allows the process to have different views on the memory between which the
> > > process can switch arbitrarily during its executing.
> > >
> > > This feature can be used in various different ways. For example to compartmentalize a
> > > process for security reasons or to improve the performance of data-centric
> > > applications.
> > >
> > > However, before I intend to submit the patchset to LKML, I first like to perform
> > > some benchmarks to identify possible performance drawbacks introduced by my changes
> > > to the original memory management architecture. Hence, I would like to ask if anyone
> > > of you could point me to some benchmarks which I can run to test my patchset and
> > > compare it against the original implementation.
> > >
> > > If there are any questions, please feel free to ask me. I am happy to answer any
> > > question related to the patchset and its idea/intention.
> > >
> > > Regards
> > > Till
> > >
> > > P.S.: Please keep me in the CC since I am not subscribed to this mailing list.
> > >
> > > [1] http://impact.crhc.illinois.edu/shared/Papers/ASPLOS16-SpaceJMP.pdf
> > 
> > https://github.com/gormanm/mmtests
> > 
> And please take a look at linux-4.9/tools/testing/selftests/vm. 
> 
> The last resort seems to ask Mel on linux-mm for 
> howtos he knows.
> 	Mel Gorman <mgorman@techsingularity.net>
> 
> Good luck
> Hillf

Hi David and Hillf,

Thank you very much for your feedback. Both of your suggestions were very helpful. I
could find some bugs in my implementation and also identified two minor performance
problems that I could fix easily.

Thanks,

Till

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

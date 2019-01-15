Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 642638E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 00:32:39 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id v3so1706370itf.4
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 21:32:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o185sor4000358ito.8.2019.01.14.21.32.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 21:32:38 -0800 (PST)
MIME-Version: 1.0
References: <20190114082416.30939-1-mhocko@kernel.org> <87pnszzg9s.fsf@concordia.ellerman.id.au>
In-Reply-To: <87pnszzg9s.fsf@concordia.ellerman.id.au>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Tue, 15 Jan 2019 13:32:26 +0800
Message-ID: <CAFgQCTsEtjKnCdUb=0d9aTNL94L1=XQGDtot=2MqmqQ-fqmr1g@mail.gmail.com>
Subject: Re: [RFC PATCH] x86, numa: always initialize all possible nodes
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <peterz@infradead.org>, x86@kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Tony Luck <tony.luck@intel.com>, linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

[...]
> >
> > I would appreciate a help with those architectures because I couldn't
> > really grasp how the memoryless nodes are really initialized there. E.g.
> > ppc only seem to call setup_node_data for online nodes but I couldn't
> > find any special treatment for nodes without any memory.
>
> We have a somewhat dubious hack in our hotplug code, see:
>
> e67e02a544e9 ("powerpc/pseries: Fix cpu hotplug crash with memoryless nodes")
>
> Which basically onlines the node when we hotplug a CPU into it.
>
This bug should be related with the present state of numa node during
boot time. On PowerNV and PSeries, the boot code seems not to bring up
all nodes if memoryless. Then it can not avoid this bug.

Thanks,
Pingfan

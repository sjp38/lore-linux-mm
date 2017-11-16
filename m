Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A65B26B0033
	for <linux-mm@kvack.org>; Thu, 16 Nov 2017 17:41:41 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id x63so806129wmf.2
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 14:41:41 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b193sor701751wmd.5.2017.11.16.14.41.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 Nov 2017 14:41:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171116212904.GA4823@redhat.com>
References: <CAA_GA1ff4mGKfxxRpjYCRjXOvbUuksM0K2gmH1VrhL4qtGWFbw@mail.gmail.com>
 <20170926161635.GA3216@redhat.com> <0d7273c3-181c-6d68-3c5f-fa518e782374@huawei.com>
 <20170930224927.GC6775@redhat.com> <CAA_GA1dhrs7n-ewZmW4bNtouK8rKnF1_TWv0z+2vrUgJjWpnMQ@mail.gmail.com>
 <20171012153721.GA2986@redhat.com> <CAAsGZS7JeH-cxrmZAVraLm5RjSVHJLXMdwZQ7Cxm91KGdVQocg@mail.gmail.com>
 <20171116024425.GC2934@redhat.com> <CAAsGZS5eoSK=Hd5av2bkw=chPGyfOYYNbrdizzCqq2gZ7+XH_g@mail.gmail.com>
 <CAAsGZS43n2_f9sQXGH5Ap=eEx2f099CDwHC0aTTgOEbw7Dc=zg@mail.gmail.com> <20171116212904.GA4823@redhat.com>
From: chetan L <loke.chetan@gmail.com>
Date: Thu, 16 Nov 2017 14:41:39 -0800
Message-ID: <CAAsGZS7oCjHuUTUAUadb+F+drp3KgDARuaOaSBbW-8RWbJBDMA@mail.gmail.com>
Subject: Re: [PATCH 0/6] Cache coherent device memory (CDM) with HMM v5
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Bob Liu <lliubbo@gmail.com>, David Nellans <dnellans@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Linux MM <linux-mm@kvack.org>, Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-accelerators@lists.ozlabs.org

On Thu, Nov 16, 2017 at 1:29 PM, Jerome Glisse <jglisse@redhat.com> wrote:

>
> For the NUMA discussion this is related to CPU less node ie not wanting
> to add any more CPU less node (node with only memory) and they are other
> aspect too. For instance you do not necessarily have good informations
> from the device to know if a page is access a lot by the device (this
> kind of information is often only accessible by the device driver). Thus

@Jerome - one comment w.r.t 'do not necessarily have good info on
device access'.

So you could be assuming a few things here :). CCIX extends the CPU
complex's coherency domain(it is now a single/unified coherency
domain). The CCIX-EP (lets say an accelerator/XPU or a NIC or a combo)
is now a true peer w.r.t the host-numa-node(s) (aka 1st class
citizen). I don't know how much info was revealed at the latest ARM
techcon where CCIX was presented. So I cannot divulge any further
details until I see that slide deck. However, you can safely assume
that the host will have *all* the info w.r.t the device-access and
vice-versa.

Chetan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

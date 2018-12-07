Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C10666B7CFD
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 04:40:23 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id e17so1699466edr.7
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 01:40:23 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i26-v6sor937775ejz.40.2018.12.07.01.40.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Dec 2018 01:40:22 -0800 (PST)
MIME-Version: 1.0
References: <CAFgQCTuyKBZdwWG=fOECE6J8DbZJsErJOyXTrLT0Kog3ec7vhw@mail.gmail.com>
 <20181205092148.GA1286@dhcp22.suse.cz> <CAFgQCTtj4m637tAzConCfeWQXSrWeNY-DLD5=f9-ZSmJMRe31Q@mail.gmail.com>
 <186b1804-3b1e-340e-f73b-f3c7e69649f5@suse.cz> <CAFgQCTv5-jeqwRVkJuDHvv0vq6uCzfdV2ZmVAU3eUzn2w2ReEQ@mail.gmail.com>
 <20181206082806.GB1286@dhcp22.suse.cz> <CAFgQCTsMdQSRFruZRGBuo30TjfiQ=sbrf9kUJAGgwN6uw+LsBw@mail.gmail.com>
 <CAFgQCTv7ADVW3WvB0tuqpL1U2MFGADA113MUm6ZmVcgvqyBfTA@mail.gmail.com>
 <20181206121152.GH1286@dhcp22.suse.cz> <CAFgQCTuqn32_pZrLBDNvC_0Aepv2F7KF7rk2nAbxmYF45KfT2w@mail.gmail.com>
 <20181207075322.GS1286@dhcp22.suse.cz>
In-Reply-To: <20181207075322.GS1286@dhcp22.suse.cz>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Fri, 7 Dec 2018 17:40:09 +0800
Message-ID: <CAFgQCTsFBUcOE9UKQ2vz=hg2FWp_QurZMQmJZ2wYLBqXkFHKHQ@mail.gmail.com>
Subject: Re: [PATCH] mm/alloc: fallback to first node if the wanted node offline
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

On Fri, Dec 7, 2018 at 3:53 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 07-12-18 10:56:51, Pingfan Liu wrote:
> [...]
> > In a short word, the fix method should consider about the two factors:
> > semantic of online-node and the effect on all archs
>
> I am pretty sure there is a lot of room for unification in this area.
> Nevertheless I strongly believe the bug should be fixed firs with the
> simplest way and all the cleanup should be done on top.
>
> Do I get it right that the diff worked for you and I can prepare a full
> patch?
>
Sure, I am glad to test you new patch.

Thanks,
Pingfan

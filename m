Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 195C78E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 09:50:15 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id v4so2020014edm.18
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 06:50:15 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n14si1431518edy.344.2018.12.07.06.50.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Dec 2018 06:50:13 -0800 (PST)
Date: Fri, 7 Dec 2018 15:50:11 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/alloc: fallback to first node if the wanted node
 offline
Message-ID: <20181207145011.GF1286@dhcp22.suse.cz>
References: <CAFgQCTsMdQSRFruZRGBuo30TjfiQ=sbrf9kUJAGgwN6uw+LsBw@mail.gmail.com>
 <CAFgQCTv7ADVW3WvB0tuqpL1U2MFGADA113MUm6ZmVcgvqyBfTA@mail.gmail.com>
 <20181206121152.GH1286@dhcp22.suse.cz>
 <CAFgQCTuqn32_pZrLBDNvC_0Aepv2F7KF7rk2nAbxmYF45KfT2w@mail.gmail.com>
 <20181207075322.GS1286@dhcp22.suse.cz>
 <CAFgQCTsFBUcOE9UKQ2vz=hg2FWp_QurZMQmJZ2wYLBqXkFHKHQ@mail.gmail.com>
 <20181207113044.GB1286@dhcp22.suse.cz>
 <CAFgQCTuf95pJSWDc1BNQ=gN76aJ_dtxMRbAV9a28X6w8vapdMQ@mail.gmail.com>
 <20181207142240.GC1286@dhcp22.suse.cz>
 <CAFgQCTuu54oZWKq_ppEvZFb4Mz31gVmsa37gTap+e9KbE=T0aQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFgQCTuu54oZWKq_ppEvZFb4Mz31gVmsa37gTap+e9KbE=T0aQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

On Fri 07-12-18 22:27:13, Pingfan Liu wrote:
> On Fri, Dec 7, 2018 at 10:22 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Fri 07-12-18 21:20:17, Pingfan Liu wrote:
> > [...]
> > > Hi Michal,
> > >
> > > As I mentioned in my previous email, I have manually apply the patch,
> > > and the patch can not work for normal bootup.
> >
> > I am sorry, I have misread your previous response. Is there anything
> > interesting on the serial console by any chance?
> 
> Nothing. It need more effort to debug. But as I mentioned, enable all
> of the rest possible node, then it works. Maybe it can give some help
> for you.

I will have a look. Thanks!

-- 
Michal Hocko
SUSE Labs

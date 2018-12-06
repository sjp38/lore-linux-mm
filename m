Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 34CFF6B79DF
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 07:11:55 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id v4so265516edm.18
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 04:11:55 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g25-v6si179629ejr.299.2018.12.06.04.11.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 04:11:53 -0800 (PST)
Date: Thu, 6 Dec 2018 13:11:52 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/alloc: fallback to first node if the wanted node
 offline
Message-ID: <20181206121152.GH1286@dhcp22.suse.cz>
References: <CAFgQCTv56drDBx-sTr6KdeQNKJnojG3g_a-k8wKe_q2y9w9NtA@mail.gmail.com>
 <20181204085601.GC1286@dhcp22.suse.cz>
 <CAFgQCTuyKBZdwWG=fOECE6J8DbZJsErJOyXTrLT0Kog3ec7vhw@mail.gmail.com>
 <20181205092148.GA1286@dhcp22.suse.cz>
 <CAFgQCTtj4m637tAzConCfeWQXSrWeNY-DLD5=f9-ZSmJMRe31Q@mail.gmail.com>
 <186b1804-3b1e-340e-f73b-f3c7e69649f5@suse.cz>
 <CAFgQCTv5-jeqwRVkJuDHvv0vq6uCzfdV2ZmVAU3eUzn2w2ReEQ@mail.gmail.com>
 <20181206082806.GB1286@dhcp22.suse.cz>
 <CAFgQCTsMdQSRFruZRGBuo30TjfiQ=sbrf9kUJAGgwN6uw+LsBw@mail.gmail.com>
 <CAFgQCTv7ADVW3WvB0tuqpL1U2MFGADA113MUm6ZmVcgvqyBfTA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFgQCTv7ADVW3WvB0tuqpL1U2MFGADA113MUm6ZmVcgvqyBfTA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

On Thu 06-12-18 18:44:03, Pingfan Liu wrote:
> On Thu, Dec 6, 2018 at 6:03 PM Pingfan Liu <kernelfans@gmail.com> wrote:
[...]
> > Which commit is this patch applied on? I can not apply it on latest linux tree.
> >
> I applied it by manual, will see the test result. I think it should
> work since you instance all the node.
> But there are two things worth to consider:
> -1st. why x86 do not bring up all nodes by default, apparently it will
> be more simple by that way

What do you mean? Why it didn't bring up before? Or do you see some
nodes not being brought up after this patch?

> -2nd. there are other archs, do they obey the rules?

I am afraid that each arch does its own initialization.
-- 
Michal Hocko
SUSE Labs

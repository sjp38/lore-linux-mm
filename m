Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B111E8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 04:23:19 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id f69so9922596pff.5
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 01:23:19 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c12si19397337pgb.402.2019.01.11.01.23.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 01:23:18 -0800 (PST)
Date: Fri, 11 Jan 2019 10:23:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/alloc: fallback to first node if the wanted node
 offline
Message-ID: <20190111092315.GB14956@dhcp22.suse.cz>
References: <20181210123738.GN1286@dhcp22.suse.cz>
 <CAFgQCTupPc1rKv2SrmWD+eJ0H6PRaizPBw3+AG67_PuLA2SKFw@mail.gmail.com>
 <20181212115340.GQ1286@dhcp22.suse.cz>
 <CAFgQCTuhW6sPtCNFmnz13p30v3owE3Rty5WJNgtqgz8XaZT-aQ@mail.gmail.com>
 <CAFgQCTtFZ8ku7W_7rcmrbmH4Qvsv7zgOSHKfPSpNSkVjYkPfBg@mail.gmail.com>
 <20181217132926.GM30879@dhcp22.suse.cz>
 <CAFgQCTubm9B1_zM+oc1GLfOChu+XY9N4OcjyeDgk6ggObRtMKg@mail.gmail.com>
 <20181220091934.GC14234@dhcp22.suse.cz>
 <20190108143440.GU31793@dhcp22.suse.cz>
 <CAFgQCTtdJ1mR6v2Y3ojHSmjg9U90cAUddhxG3Y_8zNDR5Aw9oQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFgQCTtdJ1mR6v2Y3ojHSmjg9U90cAUddhxG3Y_8zNDR5Aw9oQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

On Fri 11-01-19 11:12:45, Pingfan Liu wrote:
[...]
> Hi, this patch works! Feel free to use tested-by me

Thanks a lot for your testing! Now it is time to seriously think whether
this is the right thing to do and sync all other arches that might have
the same problem. I will take care of it. Thanks for your patience and
effort. I will post something hopefully soon in a separate thread as
this one grown too large already.

-- 
Michal Hocko
SUSE Labs

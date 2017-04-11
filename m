Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id BD1F66B0397
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 05:53:36 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id o36so17074657qtb.2
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 02:53:36 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f1si15959196qtb.29.2017.04.11.02.53.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Apr 2017 02:53:35 -0700 (PDT)
Date: Tue, 11 Apr 2017 11:53:22 +0200
From: Igor Mammedov <imammedo@redhat.com>
Subject: Re: [PATCH -v2 0/9] mm: make movable onlining suck less
Message-ID: <20170411115322.669c435d@nial.brq.redhat.com>
In-Reply-To: <20170411084142.GB6729@dhcp22.suse.cz>
References: <20170410110351.12215-1-mhocko@kernel.org>
	<20170410162749.7d7f31c1@nial.brq.redhat.com>
	<20170410145639.GE4618@dhcp22.suse.cz>
	<20170411100152.6b4be896@nial.brq.redhat.com>
	<20170411084142.GB6729@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tobias Regnery <tobias.regnery@gmail.com>

On Tue, 11 Apr 2017 10:41:42 +0200
Michal Hocko <mhocko@kernel.org> wrote:

> On Tue 11-04-17 10:01:52, Igor Mammedov wrote:
> > On Mon, 10 Apr 2017 16:56:39 +0200
> > Michal Hocko <mhocko@kernel.org> wrote:  
> [...]
> > > > #echo online_kernel > memory32/state
> > > > write error: Invalid argument
> > > > // that's not what's expected    
> > > 
> > > this is proper behavior with the current implementation. Does anything
> > > depend on the zone reusing?  
> > if we didn't have zone imbalance issue in design,
> > the it wouldn't matter but as it stands it's not
> > minore issue.
> > 
> > Consider following,
> > one hotplugs some memory and onlines it as movable,
> > then one needs to hotplug some more but to do so 
> > one one needs more memory from zone NORMAL and to keep
> > zone balance some memory in MOVABLE should be reonlined
> > as NORMAL  
> 
> Is this something that we absolutely have to have right _now_? Or are you
> OK if I address this in follow up series? Because it will make the
> current code slightly more complex and to be honest I would rather like
> to see this "core" merge and build more on top.
It's fine by me to do it on top.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

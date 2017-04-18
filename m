Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8C0196B0038
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 15:54:41 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id h19so315827wmi.10
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 12:54:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h7si188871wrc.138.2017.04.18.12.54.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Apr 2017 12:54:40 -0700 (PDT)
Date: Tue, 18 Apr 2017 21:54:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH -v2 0/9] mm: make movable onlining suck less
Message-ID: <20170418195435.GB20671@dhcp22.suse.cz>
References: <20170410110351.12215-1-mhocko@kernel.org>
 <20170411170317.GB21171@dhcp22.suse.cz>
 <CAA9_cmdrNZkOByvSecmocqs=6o8ZP5bz+Zx6NrwqjU66C=5Y4w@mail.gmail.com>
 <20170418071456.GD22360@dhcp22.suse.cz>
 <CAA9_cmfxa8QO=8-FeXWAg7iBrGh0LrZM4C=vWA5xb2ADLtO4Rw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA9_cmfxa8QO=8-FeXWAg7iBrGh0LrZM4C=vWA5xb2ADLtO4Rw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tobias Regnery <tobias.regnery@gmail.com>

On Tue 18-04-17 09:42:57, Dan Williams wrote:
> On Tue, Apr 18, 2017 at 12:14 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Mon 17-04-17 14:51:12, Dan Williams wrote:
> >> On Tue, Apr 11, 2017 at 10:03 AM, Michal Hocko <mhocko@kernel.org> wrote:
> >> > All the reported issue seem to be fixed and pushed to my git tree
> >> > attempts/rewrite-mem_hotplug branch. I will wait a day or two for more
> >> > feedback and then repost for the inclusion. I would really appreaciate
> >> > more testing/review!
> >>
> >> This still seems to be based on 4.10? It's missing some block-layer
> >> fixes and other things that trigger failures in the nvdimm unit tests.
> >> Can you rebase to a more recent 4.11-rc?
> >
> > OK, I will rebase on top of linux-next. This has been based on mmotm
> > tree so far. Btw. is there anything that would change the current
> > implementation other than small context tweaks? In other words, do you
> > see any issues with the current implementation regarding nvdimm's
> > ZONE_DEVICE usage?
> 
> I don't foresee any issues, but I wanted to be able to run the latest
> test suite to be sure.

OK, the rebase on top of the current linux-next is in my git tree [1]
attempts/rewrite-mem_hotplug branch. I will post the full series
tomorrow hopefully.

[1] git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

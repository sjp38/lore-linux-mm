Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 15B716B0092
	for <linux-mm@kvack.org>; Wed, 27 May 2015 10:38:29 -0400 (EDT)
Received: by qkhg32 with SMTP id g32so6638725qkh.0
        for <linux-mm@kvack.org>; Wed, 27 May 2015 07:38:28 -0700 (PDT)
Received: from mail-qk0-x229.google.com (mail-qk0-x229.google.com. [2607:f8b0:400d:c09::229])
        by mx.google.com with ESMTPS id 145si11373135qhb.22.2015.05.27.07.38.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 May 2015 07:38:28 -0700 (PDT)
Received: by qkdn188 with SMTP id n188so6609735qkd.2
        for <linux-mm@kvack.org>; Wed, 27 May 2015 07:38:27 -0700 (PDT)
Date: Wed, 27 May 2015 10:38:22 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 05/36] HMM: introduce heterogeneous memory management v3.
Message-ID: <20150527143821.GC1948@gmail.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
 <1432236705-4209-6-git-send-email-j.glisse@gmail.com>
 <87twuylgc2.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <87twuylgc2.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Jatin Kumar <jakumar@nvidia.com>, linux-rdma@vger.kernel.org

On Wed, May 27, 2015 at 11:20:05AM +0530, Aneesh Kumar K.V wrote:
> j.glisse@gmail.com writes:

Noted your grammar fixes.

> > diff --git a/mm/Kconfig b/mm/Kconfig
> > index 52ffb86..189e48f 100644
> > --- a/mm/Kconfig
> > +++ b/mm/Kconfig
> > @@ -653,3 +653,18 @@ config DEFERRED_STRUCT_PAGE_INIT
> >  	  when kswapd starts. This has a potential performance impact on
> >  	  processes running early in the lifetime of the systemm until kswapd
> >  	  finishes the initialisation.
> > +
> > +if STAGING
> > +config HMM
> > +	bool "Enable heterogeneous memory management (HMM)"
> > +	depends on MMU
> > +	select MMU_NOTIFIER
> > +	select GENERIC_PAGE_TABLE
> 
> What is GENERIC_PAGE_TABLE ?

Let over of when patch 0006 what a seperate feature that was introduced
before this patch. I failed to remove that chunk. Just ignore it.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 4F9C56B0038
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 10:14:38 -0400 (EDT)
Received: by qgdd90 with SMTP id d90so31693180qgd.3
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 07:14:38 -0700 (PDT)
Received: from mail-qk0-x22d.google.com (mail-qk0-x22d.google.com. [2607:f8b0:400d:c09::22d])
        by mx.google.com with ESMTPS id 93si3915398qgm.66.2015.08.13.07.14.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Aug 2015 07:14:37 -0700 (PDT)
Received: by qkcs67 with SMTP id s67so15779633qkc.1
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 07:14:36 -0700 (PDT)
Date: Thu, 13 Aug 2015 10:14:27 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 15/15] hmm/dummy: dummy driver for testing and showcasing
 the HMM API
Message-ID: <20150813141425.GA2122@gmail.com>
References: <1437159145-6548-1-git-send-email-jglisse@redhat.com>
 <1437159145-6548-16-git-send-email-jglisse@redhat.com>
 <alpine.DEB.2.10.1508131016070.9016@lenovo>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.10.1508131016070.9016@lenovo>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sylvain Jeaugey <sjeaugey@nvidia.com>
Cc: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jeff Law <law@redhat.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>

On Thu, Aug 13, 2015 at 03:45:40PM +0200, Sylvain Jeaugey wrote:
> Hi Jerome,
> 
> I get a compilation error when building the hmm_dummy module (undefined 
> function hmm_pte_test_select).
> 
> On Fri, 17 Jul 2015, Jerome Glisse wrote:
> > +static int dummy_mirror_pt_populate(struct hmm_mirror *mirror,
> > +                                 struct hmm_event *event)
> > [ snip ]
> > +             if (!mpte || !hmm_pte_test_valid_pfn(mpte) ||
> > +                 !hmm_pte_test_select(mpte)) {
> From what I understand, the select flag no longer exists in HMM PTE, 
> hence hmm_pte_test_select is missing.
> Removing this sanity check, the module compiles and loads correctly.

This flag is added by remote memory patchset and i forgot that test
when splitting dummy driver in 2 patch.

> Aside from that problem, is there a userspace test available which 
> interfaces with the dummy module ?

https://github.com/glisse/hmm-dummy-test-suite

I am trying to add more open source test with the dummy driver. But
they are some basic test already. Note that dummy driver is really
not meant to be use seriously beside as a test bed.

You can also find an updated patchset :

http://cgit.freedesktop.org/~glisse/linux/log/?h=hmm

I will probably repost including fixes made so far.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

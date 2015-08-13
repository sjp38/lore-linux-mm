Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0BF5C6B0038
	for <linux-mm@kvack.org>; Thu, 13 Aug 2015 09:45:58 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so37709857pac.2
        for <linux-mm@kvack.org>; Thu, 13 Aug 2015 06:45:57 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id zl8si3907415pac.37.2015.08.13.06.45.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 13 Aug 2015 06:45:57 -0700 (PDT)
Date: Thu, 13 Aug 2015 15:45:40 +0200
From: Sylvain Jeaugey <sjeaugey@nvidia.com>
Subject: Re: [PATCH 15/15] hmm/dummy: dummy driver for testing and showcasing
 the HMM API
In-Reply-To: <1437159145-6548-16-git-send-email-jglisse@redhat.com>
Message-ID: <alpine.DEB.2.10.1508131016070.9016@lenovo>
References: <1437159145-6548-1-git-send-email-jglisse@redhat.com> <1437159145-6548-16-git-send-email-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="8323329-583387059-1439453849=:9016"
Content-ID: <alpine.DEB.2.10.1508131018071.9016@lenovo>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron
 Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jeff Law <law@redhat.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>

--8323329-583387059-1439453849=:9016
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.10.1508131018072.9016@lenovo>

Hi Jerome,

I get a compilation error when building the hmm_dummy module (undefined 
function hmm_pte_test_select).

On Fri, 17 Jul 2015, Jerome Glisse wrote:
> +static int dummy_mirror_pt_populate(struct hmm_mirror *mirror,
> +                                 struct hmm_event *event)
> [ snip ]
> +             if (!mpte || !hmm_pte_test_valid_pfn(mpte) ||
> +                 !hmm_pte_test_select(mpte)) {
>From what I understand, the select flag no longer exists in HMM PTE, 
hence hmm_pte_test_select is missing.
Removing this sanity check, the module compiles and loads correctly.

Aside from that problem, is there a userspace test available which 
interfaces with the dummy module ?

Thanks,
Sylvain
--8323329-583387059-1439453849=:9016--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

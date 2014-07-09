Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id CEA666B0031
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 12:24:57 -0400 (EDT)
Received: by mail-we0-f180.google.com with SMTP id x48so7732566wes.11
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 09:24:57 -0700 (PDT)
Received: from mail.8bytes.org (8bytes.org. [2a01:238:4242:f000:64f:6c43:3523:e535])
        by mx.google.com with ESMTP id i7si8731343wiz.5.2014.07.09.09.24.56
        for <linux-mm@kvack.org>;
        Wed, 09 Jul 2014 09:24:56 -0700 (PDT)
Received: from localhost (localhost [127.0.0.1])
	by mail.8bytes.org (Postfix) with SMTP id 5B2A712B044
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 18:24:56 +0200 (CEST)
Date: Wed, 9 Jul 2014 18:24:53 +0200
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 2/8] mm: differentiate unmap for vmscan from other unmap.
Message-ID: <20140709162453.GO1958@8bytes.org>
References: <1404856801-11702-1-git-send-email-j.glisse@gmail.com>
 <1404856801-11702-3-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1404856801-11702-3-git-send-email-j.glisse@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: j.glisse@gmail.com
Cc: akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 08, 2014 at 05:59:59PM -0400, j.glisse@gmail.com wrote:
> From: Jerome Glisse <jglisse@redhat.com>
> 
> New code will need to be able to differentiate [...]

Why?

> between a regular unmap and an unmap trigger by vmscan in which case
> we want to be as quick as possible.

Why want you be slower as possible in the other case?


	Joerg


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

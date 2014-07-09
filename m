Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f176.google.com (mail-vc0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 1AFD56B0035
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 13:24:13 -0400 (EDT)
Received: by mail-vc0-f176.google.com with SMTP id ik5so7473967vcb.7
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 10:24:12 -0700 (PDT)
Received: from mail-vc0-x22a.google.com (mail-vc0-x22a.google.com [2607:f8b0:400c:c03::22a])
        by mx.google.com with ESMTPS id jd6si15211476veb.87.2014.07.09.10.24.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Jul 2014 10:24:12 -0700 (PDT)
Received: by mail-vc0-f170.google.com with SMTP id hy10so7562956vcb.15
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 10:24:11 -0700 (PDT)
Date: Wed, 9 Jul 2014 13:24:26 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 2/8] mm: differentiate unmap for vmscan from other unmap.
Message-ID: <20140709172425.GC4249@gmail.com>
References: <1404856801-11702-1-git-send-email-j.glisse@gmail.com>
 <1404856801-11702-3-git-send-email-j.glisse@gmail.com>
 <20140709162453.GO1958@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20140709162453.GO1958@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 09, 2014 at 06:24:53PM +0200, Joerg Roedel wrote:
> On Tue, Jul 08, 2014 at 05:59:59PM -0400, j.glisse@gmail.com wrote:
> > From: Jerome Glisse <jglisse@redhat.com>
> > 
> > New code will need to be able to differentiate [...]
> 
> Why?
> 
> > between a regular unmap and an unmap trigger by vmscan in which case
> > we want to be as quick as possible.
> 
> Why want you be slower as possible in the other case?
> 

Well i should probably have updated the commit message. Trying to be
faster is one side of the coin. The other is to actualy know that the
page is considered for reclaim which is useful information in itself.
Secondary user of the page might want to mark the page as recently use
and move it to the active list.

In most case an unmap event is not as critical as a vmscan can be (note
that this depend on the current states of memory resources if they are
scarce or not). While right now there is no special code inside hmm for
offering a fast path this is definitly something that is envision on
some hardware.

Again it is all about trying to take best course of action depending on
context and the more informations we have about current context the easier
it is to properly choose.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f41.google.com (mail-yh0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3658C280025
	for <linux-mm@kvack.org>; Mon, 10 Nov 2014 16:47:03 -0500 (EST)
Received: by mail-yh0-f41.google.com with SMTP id i57so3699034yha.14
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 13:47:03 -0800 (PST)
Received: from mail-yh0-x233.google.com (mail-yh0-x233.google.com. [2607:f8b0:4002:c01::233])
        by mx.google.com with ESMTPS id k125si19005469yka.107.2014.11.10.13.47.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Nov 2014 13:47:02 -0800 (PST)
Received: by mail-yh0-f51.google.com with SMTP id c41so1225486yho.38
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 13:47:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFwwKV_D5oWT6a97a70G7OnvsPD_j9LsuR+_e4MEdCOO9A@mail.gmail.com>
References: <1415644096-3513-1-git-send-email-j.glisse@gmail.com>
	<1415644096-3513-4-git-send-email-j.glisse@gmail.com>
	<CA+55aFwHd4QYopHvd=H6hxoQeqDV3HT6=436LGU-FRb5A0p7Vg@mail.gmail.com>
	<20141110205814.GA4186@gmail.com>
	<CA+55aFwwKV_D5oWT6a97a70G7OnvsPD_j9LsuR+_e4MEdCOO9A@mail.gmail.com>
Date: Mon, 10 Nov 2014 13:47:01 -0800
Message-ID: <CA+55aFyh1ZOuLZw5Vb_ZTYhSsbwdqRFOceYSj7nh02NmKxy4AQ@mail.gmail.com>
Subject: Re: [PATCH 3/5] lib: lockless generic and arch independent page table
 (gpt) v2.
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Joerg Roedel <joro@8bytes.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>

On Mon, Nov 10, 2014 at 1:35 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> Or do you actually have a setup where actual non-CPU hardware actually
> walks the page tables you create and call "page tables"?

So just to clarify: I haven't looked at all your follow-up patches at
all, although I've seen the overviews in earlier versions. When trying
to read through the latest version, I got stuck on this one, and felt
it was crazy.

But maybe I'm misreading it and it actually has good reasons for it.
But just from the details I look at, some of it looks too incestuous
with the system (the split PTL lock use), other parts look really
really odd (like the 64-bit shift counts), and some of it looks just
plain buggy (the bitops for synchronization). And none of it is all
that easy to actually read.

                        Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

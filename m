Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id E4AB26B00BE
	for <linux-mm@kvack.org>; Thu,  6 Nov 2014 12:17:24 -0500 (EST)
Received: by mail-qa0-f43.google.com with SMTP id j7so1068115qaq.30
        for <linux-mm@kvack.org>; Thu, 06 Nov 2014 09:17:24 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m79si12843416qgm.19.2014.11.06.09.17.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Nov 2014 09:17:23 -0800 (PST)
Message-ID: <545BACF4.2080808@redhat.com>
Date: Thu, 06 Nov 2014 12:16:36 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] mmu_notifier: add event information to address invalidation
 v5
References: <1415047353-29160-1-git-send-email-j.glisse@gmail.com> <1415047353-29160-2-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1415047353-29160-2-git-send-email-j.glisse@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: j.glisse@gmail.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 11/03/2014 03:42 PM, j.glisse@gmail.com wrote:
> From: JA(C)rA'me Glisse <jglisse@redhat.com>
> 
> The event information will be usefull for new user of mmu_notifier
> API. The event argument differentiate between a vma disappearing, a
> page being write protected or simply a page being unmaped. This
> allow new user to take different path for different event for
> instance on unmap the resource used to track a vma are still valid
> and should stay around. While if the event is saying that a vma is
> being destroy it means that any resources used to track this vma
> can be free.

Looks good. All I found was one spelling mistake :)

> + *   - MMU_WRITE_BACK: memory is being written back to disk, all
> write accesses + *     must stop after invalidate_range_start
> callback returns. Read access are + *     still allowed. + * + *
> - MMU_WRITE_PROTECT: memory is being writte protected (ie should be
> mapped

                                             "write protected"

> + *     read only no matter what the vma memory protection allows).
> All write + *     accesses must stop after invalidate_range_start
> callback returns. Read + *     access are still allowed.

After fixing the spelling mistake, feel free to add my

Reviewed-by: Rik van Riel <riel@redhat.com>

- -- 
All rights reversed
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJUW6z0AAoJEM553pKExN6DN3wIALqZPmNihc/AbOc6MCnp+two
do5pO0DTl61AD0SmPsjSKrADa8deHKDL3PqsEcA7aYOlwrJOkPhNxZZsq1SHscAO
iw4Ar9BbI0JwBZO4xq4RwFhAVnu5r5NZEcyG1t1EqOGoOVc8NIflTNCxQYOU+vkj
YxCZb4A0+e6nKe3P+tWso69AGHH5GVvFOqLy709OxneLbTVDRRBM1KzYtdkGR62i
u3Xa41WGVjAa6OVYEoENloa/o8cmL9vgqPG3bhbCjR8zpBPAQ7fS3g8Ckux72mS+
UNzyoZjCGpWg7IxF94xhTvydzER0XDMancbKzrYW14YoJ3mW7ZDj58vpK25SKM8=
=f2u6
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

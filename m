Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2479E6B00FF
	for <linux-mm@kvack.org>; Fri,  7 Nov 2014 16:38:23 -0500 (EST)
Received: by mail-qg0-f43.google.com with SMTP id f51so3027395qge.2
        for <linux-mm@kvack.org>; Fri, 07 Nov 2014 13:38:23 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y20si18828791qay.99.2014.11.07.13.38.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Nov 2014 13:38:22 -0800 (PST)
Message-ID: <545D3BA2.90604@redhat.com>
Date: Fri, 07 Nov 2014 16:37:38 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/5] hmm/dummy: dummy driver to showcase the hmm api v3
References: <1415047353-29160-1-git-send-email-j.glisse@gmail.com> <1415047353-29160-6-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1415047353-29160-6-git-send-email-j.glisse@gmail.com>
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
> This is a dummy driver which full fill two purposes : - showcase
> the hmm api and gives references on how to use it. - provide an
> extensive user space api to stress test hmm.
> 
> This is a particularly dangerous module as it allow to access a 
> mirror of a process address space through its device file. Hence it
> should not be enabled by default and only people actively 
> developing for hmm should use it.
> 
> Changed since v1: - Fixed all checkpatch.pl issue (ignoreing some
> over 80 characters).
> 
> Changed since v2: - Rebase and adapted to lastest change.
> 
> Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

- -- 
All rights reversed
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJUXTuhAAoJEM553pKExN6DF4EH/2sC7XPaKG5utzuuP1Jo5R1F
i9PuWpU3gMrgzeRR5/31MlmP+9uz6FDDtHb8fP4evp+rhyMvyFidFHAvtijmAhuj
T3tR+jPzMbJHk/JJX6JRHjRaErvTdIcFvSyWnLE8caaMWiQs7CqOj3jDIreCJW2x
89irX3HGLGsga9Uu9xwuF8UiGmrbLaPnICJ6Qqy94yYdxI9JlohYlqlDv+ouq9wp
Kv3tk0UwY83JtIqyDrCw70twY1hw8ApQWPKW6DdXYGSplY/na2JJE8qRte1BtAZ7
AUCE05v62r8YcSWgljN2txZETXyCmXELIgMchRXQGdXvICMZNMYiSM1zbW4Fjnk=
=dYPc
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

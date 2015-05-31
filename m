Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id E838B6B0032
	for <linux-mm@kvack.org>; Sun, 31 May 2015 02:56:04 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so1629972pdj.3
        for <linux-mm@kvack.org>; Sat, 30 May 2015 23:56:04 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0088.outbound.protection.outlook.com. [157.55.234.88])
        by mx.google.com with ESMTPS id cy3si15932530pdb.175.2015.05.30.23.56.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 30 May 2015 23:56:03 -0700 (PDT)
Message-ID: <556AB086.2030305@mellanox.com>
Date: Sun, 31 May 2015 09:56:06 +0300
From: Haggai Eran <haggaie@mellanox.com>
MIME-Version: 1.0
Subject: Re: HMM (Heterogeneous Memory Management) v8
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: j.glisse@gmail.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes
 Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van
 Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron
 Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul
 Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, linux-fsdevel@vger.kernel.org, Linda
 Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jeff Law <law@redhat.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>

On 21/05/2015 22:31, j.glisse@gmail.com wrote:
> From design point of view not much changed since last patchset (2).
> Most of the change are in small details of the API expose to device
> driver. This version also include device driver change for Mellanox
> hardware to use HMM as an alternative to ODP (which provide a subset
> of HMM functionality specificaly for RDMA devices). Long term plan
> is to have HMM completely replace ODP.

Hi,

I think HMM would be a good long term solution indeed. For now I would
want to keep ODP and HMM side by side (as the patchset seem to do)
mainly since HMM is introduced as a STAGING feature and ODP is part of
the mainline kernel.

It would be nice if you could provide a git repository to access the
patches. I couldn't apply them to the current linux-next tree.

A minor thing: I noticed some style issues in the patches. You should
run checkpatch.pl on the patches and get them to match the coding style.

Regards,
Haggai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

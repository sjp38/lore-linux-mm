Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id C60FD6B0044
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 14:41:30 -0400 (EDT)
Received: by mail-qg0-f42.google.com with SMTP id j5so3836716qga.29
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 11:41:30 -0700 (PDT)
Received: from na01-bl2-obe.outbound.protection.outlook.com (mail-bl2lp0204.outbound.protection.outlook.com. [207.46.163.204])
        by mx.google.com with ESMTPS id b38si12428608qge.71.2014.07.24.11.41.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 24 Jul 2014 11:41:30 -0700 (PDT)
Message-ID: <53D15349.7030506@amd.com>
Date: Thu, 24 Jul 2014 21:41:13 +0300
From: Oded Gabbay <oded.gabbay@amd.com>
MIME-Version: 1.0
Subject: Re: mmu_notifier: preparatory patches for hmm and or iommuv2 v6
References: <1405622809-3797-1-git-send-email-j.glisse@gmail.com>
 <20140724154646.GB2951@gmail.com>
In-Reply-To: <20140724154646.GB2951@gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel
 Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes
 Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van
 Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron
 Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul
 Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>

On 24/07/14 18:46, Jerome Glisse wrote:
> On Thu, Jul 17, 2014 at 02:46:46PM -0400, j.glisse@gmail.com wrote:
>> Nutshell few patches to improve mmu_notifier :
>>  - patch 1/3 allow to free resources when mm_struct is destroy.
>>  - patch 2/3 provide context informations to mmu_notifier listener.
>>  - patch 3/3 pass vma to range_start/range_end to avoid duplicate
>>    vma lookup inside the listener.
>>
>> I restricted myself to set of less controversial patches and i believe
>> i have addressed all comments that were previously made. Thanks again
>> for all feedback, i hope this version is the good one.
>>
>> This is somewhat of a v5 but i do not include core hmm with those
>> patches. So previous discussion thread :
>> v1 http://www.spinics.net/lists/linux-mm/msg72501.html
>> v2 http://www.spinics.net/lists/linux-mm/msg74532.html
>> v3 http://www.spinics.net/lists/linux-mm/msg74656.html
>> v4 http://www.spinics.net/lists/linux-mm/msg75401.html
>> v5 http://www.spinics.net/lists/linux-mm/msg75875.html
>>
>=20
> Anyone willing to review this ? Or is there no objection ? I would
> really appreciate to know where i am standing on those 3 patches.
>=20
> Cheers,
> J=C3=A9r=C3=B4me
>=20
I think I already wrote it but anyway, I reviewed and tested patch 1/3.

	Oded

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

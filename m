Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 592416B025F
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 11:20:02 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id u10so15940008otc.21
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 08:20:02 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u27sor8578617otc.169.2017.11.27.08.20.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 08:20:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171127161511.GE5977@quack2.suse.cz>
References: <151068938905.7446.12333914805308312313.stgit@dwillia2-desk3.amr.corp.intel.com>
 <151068939985.7446.15684639617389154187.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171127161511.GE5977@quack2.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 27 Nov 2017 08:19:59 -0800
Message-ID: <CAPcyv4iayd=dmq18he3EqW-2SO62-s93GLzf8FKWa9s_Pa1Tsw@mail.gmail.com>
Subject: Re: [PATCH v2 2/4] mm: fail get_vaddr_frames() for filesystem-dax mappings
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonyoung Shim <jy0922.shim@samsung.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Seung-Woo Kim <sw0312.kim@samsung.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, Inki Dae <inki.dae@samsung.com>, Linux MM <linux-mm@kvack.org>, Kyungmin Park <kyungmin.park@samsung.com>, Mel Gorman <mgorman@suse.de>, Mauro Carvalho Chehab <mchehab@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, "Linux-media@vger.kernel.org" <linux-media@vger.kernel.org>

On Mon, Nov 27, 2017 at 8:15 AM, Jan Kara <jack@suse.cz> wrote:
> On Tue 14-11-17 11:56:39, Dan Williams wrote:
>> Until there is a solution to the dma-to-dax vs truncate problem it is
>> not safe to allow V4L2, Exynos, and other frame vector users to create
>> long standing / irrevocable memory registrations against filesytem-dax
>> vmas.
>>
>> Cc: Inki Dae <inki.dae@samsung.com>
>> Cc: Seung-Woo Kim <sw0312.kim@samsung.com>
>> Cc: Joonyoung Shim <jy0922.shim@samsung.com>
>> Cc: Kyungmin Park <kyungmin.park@samsung.com>
>> Cc: Mauro Carvalho Chehab <mchehab@kernel.org>
>> Cc: linux-media@vger.kernel.org
>> Cc: Jan Kara <jack@suse.cz>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Cc: Vlastimil Babka <vbabka@suse.cz>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: <stable@vger.kernel.org>
>> Fixes: 3565fce3a659 ("mm, x86: get_user_pages() for dax mappings")
>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>
> Makes sense. I'd just note that in principle get_vaddr_frames() is no more
> long-term than get_user_pages(). It is just so that all the users of
> get_vaddr_frames() currently want a long-term reference. Maybe could you
> add here also a comment that the vma_is_fsdax() check is there because all
> users of this function want a long term page reference? With that you can
> add:

Ok, will do.

> Reviewed-by: Jan Kara <jack@suse.cz>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

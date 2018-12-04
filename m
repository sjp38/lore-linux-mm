Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id C5BC76B6BD1
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 19:09:19 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id 80so15077234qkd.0
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 16:09:19 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n40si387559qtf.91.2018.12.03.16.09.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 16:09:18 -0800 (PST)
Date: Mon, 3 Dec 2018 19:09:12 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 2/3] mm/mmu_notifier: use structure for
 invalidate_range_start/end calls
Message-ID: <20181204000911.GB20742@redhat.com>
References: <20181203201817.10759-1-jglisse@redhat.com>
 <20181203201817.10759-3-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181203201817.10759-3-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <zwisler@kernel.org>, Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Michal Hocko <mhocko@kernel.org>, Christian Koenig <christian.koenig@amd.com>, Felix Kuehling <felix.kuehling@amd.com>, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, kvm@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Mon, Dec 03, 2018 at 03:18:16PM -0500, jglisse@redhat.com wrote:
> diff --git a/mm/migrate.c b/mm/migrate.c
> index f7e4bfdc13b7..4896dd9d8b28 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -2303,8 +2303,13 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
>   */
>  static void migrate_vma_collect(struct migrate_vma *migrate)
>  {
> +	struct mmu_notifier_range range;
>  	struct mm_walk mm_walk;
>  
> +	range.start = migrate->start;
> +	range.end = migrate->end;
> +	range.mm = mm_walk.mm;

Andrew can you replace above line by:

+	range.mm = migrate->vma->vm_mm;

I made a mistake here when i was rebasing before posting. I checked
the patchset again and i believe this is the only mistake i made.

Do you want me to repost ?

Sorry for my stupid mistake.

Cheers,
J�r�me

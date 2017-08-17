Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4E5146B02C3
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 17:12:49 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 49so15398845wrw.12
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 14:12:49 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i90si3286362wmh.239.2017.08.17.14.12.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Aug 2017 14:12:47 -0700 (PDT)
Date: Thu, 17 Aug 2017 14:12:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [HMM-v25 13/19] mm/migrate: new migrate mode
 MIGRATE_SYNC_NO_COPY
Message-Id: <20170817141245.93cfb315cfc598ff86928639@linux-foundation.org>
In-Reply-To: <20170817000548.32038-14-jglisse@redhat.com>
References: <20170817000548.32038-1-jglisse@redhat.com>
	<20170817000548.32038-14-jglisse@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>

On Wed, 16 Aug 2017 20:05:42 -0400 J__r__me Glisse <jglisse@redhat.com> wrote:

> Introduce a new migration mode that allow to offload the copy to
> a device DMA engine. This changes the workflow of migration and
> not all address_space migratepage callback can support this. So
> it needs to be tested in those cases.

Can you please expand on this?  What additional testing must be
performed before we are able to merge this into mainline?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

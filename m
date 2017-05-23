Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id D795783292
	for <linux-mm@kvack.org>; Tue, 23 May 2017 18:02:53 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id k11so63029002qtk.4
        for <linux-mm@kvack.org>; Tue, 23 May 2017 15:02:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s40si22090846qtg.293.2017.05.23.15.02.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 May 2017 15:02:53 -0700 (PDT)
Date: Tue, 23 May 2017 18:02:49 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM 00/15] HMM (Heterogeneous Memory Management) v22
Message-ID: <20170523220248.GA23833@redhat.com>
References: <20170522165206.6284-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170522165206.6284-1-jglisse@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

Andrew i posted updated patch for 0007 0008 and 0009 as reply to orignal
patches. It includes changes Dan and Kyrill wanted to see. I added the
device_private_key to page_alloc.c to avoid modify more than 3 patches
but if you prefer i can repost a v23 serie and move the static key to
hmm.c

Also i guess posting a v23 would have it tested against builder as i
doubt automatic builder are clever enough to understand all this.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

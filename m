Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 75E0E6B0022
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 18:36:39 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id c16so4828930pgv.8
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 15:36:39 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j62si5014394pgd.404.2018.03.22.15.36.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Mar 2018 15:36:38 -0700 (PDT)
Date: Thu, 22 Mar 2018 15:36:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 04/15] mm/hmm: unregister mmu_notifier when last HMM
 client quit v3
Message-Id: <20180322153636.ad972fb547d3ff4f47498cd1@linux-foundation.org>
In-Reply-To: <20180322013025.7008-1-jglisse@redhat.com>
References: <20180321181614.9968-1-jglisse@redhat.com>
	<20180322013025.7008-1-jglisse@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, John Hubbard <jhubbard@nvidia.com>

On Wed, 21 Mar 2018 21:30:25 -0400 jglisse@redhat.com wrote:

> This code was lost in translation at one point. This properly call
> mmu_notifier_unregister_no_release() once last user is gone. This
> fix the zombie mm_struct as without this patch we do not drop the
> refcount we have on it.

OK, I'm officially all messed up and confused ;) I'll await the next
full resend, please.

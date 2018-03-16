Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id ED3D86B0025
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 17:12:23 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id j8so5775564pfh.13
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 14:12:23 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u7-v6si7157758plz.562.2018.03.16.14.12.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 14:12:23 -0700 (PDT)
Date: Fri, 16 Mar 2018 14:12:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 03/14] mm/hmm: HMM should have a callback before MM is
 destroyed v2
Message-Id: <20180316141221.f2b622630de3f1da51a5c105@linux-foundation.org>
In-Reply-To: <20180316191414.3223-4-jglisse@redhat.com>
References: <20180316191414.3223-1-jglisse@redhat.com>
	<20180316191414.3223-4-jglisse@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, stable@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, John Hubbard <jhubbard@nvidia.com>

On Fri, 16 Mar 2018 15:14:08 -0400 jglisse@redhat.com wrote:

> The hmm_mirror_register() function registers a callback for when
> the CPU pagetable is modified. Normally, the device driver will
> call hmm_mirror_unregister() when the process using the device is
> finished. However, if the process exits uncleanly, the struct_mm
> can be destroyed with no warning to the device driver.

Again, what are the user-visible effects of the bug?  Such info is
needed when others review our request for a -stable backport.  And the
many people who review -stable patches for integration into their own
kernel trees will want to understand the benefit of the patch to their
users.

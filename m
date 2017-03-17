Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 36F6E6B0038
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 23:32:55 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id e5so123006540pgk.1
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 20:32:55 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 89si7216016pla.226.2017.03.16.20.32.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 20:32:54 -0700 (PDT)
Date: Thu, 16 Mar 2017 20:32:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [HMM 07/16] mm/migrate: new memory migration helper for use
 with device memory v4
Message-Id: <20170316203253.755ab6180affcfa3a7a9a1ba@linux-foundation.org>
In-Reply-To: <2057035918.7910419.1489715543920.JavaMail.zimbra@redhat.com>
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
	<1489680335-6594-8-git-send-email-jglisse@redhat.com>
	<20170316160520.d03ac02474cad6d2c8eba9bc@linux-foundation.org>
	<d4e8433d-4680-dced-4f11-2f3cc8ebc613@nvidia.com>
	<CAKTCnzmYob5uq11zkJE781BX9rDH9EYM7zxHH+ZMtTs4D5kkiQ@mail.gmail.com>
	<94e0d115-7deb-c748-3dc2-60d6289e6551@nvidia.com>
	<2057035918.7910419.1489715543920.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: John Hubbard <jhubbard@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Thu, 16 Mar 2017 21:52:23 -0400 (EDT) Jerome Glisse <jglisse@redhat.com> wrote:

> The original intention was for it to be 64bit only, 32bit is a dying
> species and before splitting out hmm_ prefix from this code and moving
> it to be generic it was behind a 64bit flag.
> 
> If latter one someone really care about 32bit we can only move to u64

I think that's the best compromise.  If someone wants this on 32-bit
then they're free to get it working.  That "someone" will actually be
able to test it, which you clearly won't be doing!

However, please do check that the impact of this patchset on 32-bit's
`size vmlinux' is minimal.  Preferably zero.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 101596B0038
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 12:53:58 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id v127so73149316qkb.5
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 09:53:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w3si6863455qtg.225.2017.03.17.09.53.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 09:53:56 -0700 (PDT)
Date: Fri, 17 Mar 2017 12:53:51 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM 16/16] mm/hmm/devmem: dummy HMM device for ZONE_DEVICE
 memory v2
Message-ID: <20170317165351.GA16236@redhat.com>
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
 <1489680335-6594-17-git-send-email-jglisse@redhat.com>
 <e3163e6a-654d-cbf6-3aad-788c31f20655@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <e3163e6a-654d-cbf6-3aad-788c31f20655@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <liubo95@huawei.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Fri, Mar 17, 2017 at 02:55:57PM +0800, Bob Liu wrote:
> Hi Jerome,
> 
> On 2017/3/17 0:05, Jerome Glisse wrote:
> > This introduce a dummy HMM device class so device driver can use it to
> > create hmm_device for the sole purpose of registering device memory.
> 
> May I ask where is the latest dummy HMM device driver?
> I can only get this one: https://patchwork.kernel.org/patch/4352061/

https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-next

This is a 4.10 tree but the dummy driver there apply on top of v18

https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-v18

This is really an example driver it doesn't do anything useful beside
help in testing and debugging.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

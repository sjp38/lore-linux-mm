Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 87FB56B049C
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 19:05:27 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id v184so593wmf.1
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 16:05:27 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g202si1375229wmd.276.2018.01.03.16.05.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jan 2018 16:05:26 -0800 (PST)
Date: Wed, 3 Jan 2018 16:05:23 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/6] mm, hugetlb: allocation API and migration
 improvements
Message-Id: <20180103160523.2232e3c2da1728c84b160d56@linux-foundation.org>
In-Reply-To: <20180103093213.26329-1-mhocko@kernel.org>
References: <20180103093213.26329-1-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, LKML <linux-kernel@vger.kernel.org>

On Wed,  3 Jan 2018 10:32:07 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> I've posted this as an RFC [1] and both Mike and Naoya seem to be OK
> both with patches and the approach. I have rebased this on top of [2]
> because there is a small conflict in mm/mempolicy.c. I know it is late
> in the release cycle but similarly to [2] I would really like to see
> this in linux-next for a longer time for a wider testing exposure.

I'm interpreting this to mean "hold for 4.17-rc1"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

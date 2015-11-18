Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 78FF082F81
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 09:32:25 -0500 (EST)
Received: by wmec201 with SMTP id c201so281459300wme.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 06:32:25 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u128si4657564wme.112.2015.11.18.06.32.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 18 Nov 2015 06:32:24 -0800 (PST)
Date: Wed, 18 Nov 2015 15:32:17 +0100
From: Cyril Hrubis <chrubis@suse.cz>
Subject: Re: [PATCH] mm: fix incorrect behavior when process virtual address
 space limit is exceeded
Message-ID: <20151118143217.GA15346@rei>
References: <1447695379-14526-1-git-send-email-kwapulinski.piotr@gmail.com>
 <20151116205210.GB27526@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151116205210.GB27526@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>, akpm@linux-foundation.org, cmetcalf@ezchip.com, mszeredi@suse.cz, viro@zeniv.linux.org.uk, dave@stgolabs.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, jack@suse.cz, xiexiuqi@huawei.com, vbabka@suse.cz, Vineet.Gupta1@synopsys.com, oleg@redhat.com, riel@redhat.com, gang.chen.5i5j@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi!
> [CCing Cyril]

Ah I've confused the vm_flags and flags variables and nobody caught that
during the review. But still sorry that I've messed up.

Looking at the code I agree with Michal that we try to find the
intesection poinlesly even for !MAP_FIXED which slowns down mmap() tiny
little bit which should be fixed.

The fix looks good to me.

-- 
Cyril Hrubis
chrubis@suse.cz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

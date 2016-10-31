Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4C8786B0290
	for <linux-mm@kvack.org>; Mon, 31 Oct 2016 07:45:44 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 79so67834342wmy.6
        for <linux-mm@kvack.org>; Mon, 31 Oct 2016 04:45:44 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id t14si23820575wme.97.2016.10.31.04.45.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Oct 2016 04:45:42 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id p190so11804928wmp.1
        for <linux-mm@kvack.org>; Mon, 31 Oct 2016 04:45:42 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm: remove get_user_pages_locked()
References: <20161031100228.17917-1-lstoakes@gmail.com>
 <20161031100228.17917-3-lstoakes@gmail.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <cc508436-156e-eb4b-ae01-b44f33c2d692@redhat.com>
Date: Mon, 31 Oct 2016 12:45:36 +0100
MIME-Version: 1.0
In-Reply-To: <20161031100228.17917-3-lstoakes@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-cris-kernel@axis.com, linux-ia64@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, kvm@vger.kernel.org, linux-media@vger.kernel.org, devel@driverdev.osuosl.org



On 31/10/2016 11:02, Lorenzo Stoakes wrote:
> - *
> - * get_user_pages should be phased out in favor of
> - * get_user_pages_locked|unlocked or get_user_pages_fast. Nothing
> - * should use get_user_pages because it cannot pass
> - * FAULT_FLAG_ALLOW_RETRY to handle_mm_fault.

This comment should be preserved in some way.  In addition, removing
get_user_pages_locked() makes it harder (compared to a simple "git grep
-w") to identify callers that lack allow-retry functionality).  So I'm
not sure about the benefits of these patches.

If all callers were changed, then sure removing the _locked suffix would
be a good idea.

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B96046B0289
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 05:54:39 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l124so7149180wml.4
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 02:54:39 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id a8si6266129wja.149.2016.10.27.02.54.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 02:54:38 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id m83so1821907wmc.0
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 02:54:38 -0700 (PDT)
Date: Thu, 27 Oct 2016 10:54:36 +0100
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: Re: [PATCH 0/2] mm: unexport __get_user_pages_unlocked()
Message-ID: <20161027095436.GA5230@lucifer>
References: <20161027095141.2569-1-lstoakes@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161027095141.2569-1-lstoakes@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org, linux-rdma@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-fsdevel@vger.kernel.org

On Thu, Oct 27, 2016 at 10:51:39AM +0100, Lorenzo Stoakes wrote:
> This patch series continues the cleanup of get_user_pages*() functions taking
> advantage of the fact we can now pass gup_flags as we please.

Note that this patch series has an unfortunate trivial dependency on my recent
'fix up get_user_pages* comments' patch which means this series applies against
-mmots but not mainline at this point in time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

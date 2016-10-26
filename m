Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A2FFA6B0289
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 05:15:45 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id i128so12230271wme.11
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 02:15:45 -0700 (PDT)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id x14si2040247wmf.65.2016.10.26.02.15.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 02:15:44 -0700 (PDT)
Received: by mail-wm0-f41.google.com with SMTP id e69so13857239wmg.0
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 02:15:44 -0700 (PDT)
Date: Wed, 26 Oct 2016 11:15:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: remove unnecessary __get_user_pages_unlocked() calls
Message-ID: <20161026091542.GD18382@dhcp22.suse.cz>
References: <20161025233609.5601-1-lstoakes@gmail.com>
 <20161025234631.GA5946@lucifer>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161025234631.GA5946@lucifer>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 26-10-16 00:46:31, Lorenzo Stoakes wrote:
> The holdout for unexporting __get_user_pages_unlocked() is its invocation in
> mm/process_vm_access.c: process_vm_rw_single_vec(), as this definitely _does_
> seem to invoke VM_FAULT_RETRY behaviour which get_user_pages_remote() will not
> trigger if we were to replace it with the latter.

I am not sure I understand. Prior to 1e9877902dc7e this used
get_user_pages_unlocked. What prevents us from reintroducing it with
FOLL_REMOVE which was meant to be added by the above commit?

Or am I missing your point?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

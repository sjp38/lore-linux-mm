Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id BFC966B0275
	for <linux-mm@kvack.org>; Thu, 27 Oct 2016 03:06:31 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id i128so4468443wme.2
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 00:06:31 -0700 (PDT)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id b2si6743121wjv.167.2016.10.27.00.06.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Oct 2016 00:06:30 -0700 (PDT)
Received: by mail-wm0-x22e.google.com with SMTP id 140so2121632wmv.1
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 00:06:30 -0700 (PDT)
Date: Thu, 27 Oct 2016 08:06:27 +0100
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: Re: [PATCH v2] mm: remove unnecessary __get_user_pages_unlocked()
 calls
Message-ID: <20161027070627.GA4615@lucifer>
References: <20161025233609.5601-1-lstoakes@gmail.com>
 <20161026092548.12712-1-lstoakes@gmail.com>
 <20161026171207.e76e4420dd95afcf16cc7c59@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161026171207.e76e4420dd95afcf16cc7c59@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Oct 26, 2016 at 05:12:07PM -0700, Andrew Morton wrote:
> It's a KVM patch and should have been called "kvm: remove ...".
> Possibly the KVM maintainers will miss it for this reason.
>

Ah, indeed, however I think given my and Michal's discussion in this thread
regarding adjusting get_user_pages_remote() to allow for the unexporting of
__get_user_pages_unlocked() it would make more sense for me to batch up this
change with that change also (and then in fact actually be an mm patch.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

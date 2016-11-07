Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0790F6B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 06:00:54 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r68so57983598wmd.0
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 03:00:53 -0800 (PST)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id g125si9717011wma.144.2016.11.07.03.00.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 03:00:52 -0800 (PST)
Received: by mail-wm0-x22c.google.com with SMTP id t79so169341854wmt.0
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 03:00:52 -0800 (PST)
Date: Mon, 7 Nov 2016 11:00:50 +0000
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: Re: [PATCH 1/2] mm: add locked parameter to get_user_pages()
Message-ID: <20161107110050.GA25313@lucifer>
References: <20161031100228.17917-1-lstoakes@gmail.com>
 <20161031100228.17917-2-lstoakes@gmail.com>
 <20161107104918.GQ30704@axis.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161107104918.GQ30704@axis.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Nilsson <jesper.nilsson@axis.com>
Cc: linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-ia64@vger.kernel.org, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, kvm@vger.kernel.org, linux-cris-kernel@axis.com, linux-rdma@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Dave Hansen <dave.hansen@linux.intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, Michal Hocko <mhocko@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-media@vger.kernel.org

On Mon, Nov 07, 2016 at 11:49:18AM +0100, Jesper Nilsson wrote:
> For the cris-part:
> Acked-by: Jesper Nilsson <jesper.nilsson@axis.com>

Thanks very much for that, however just to avoid any confusion, I realised this
series was not not the right way forward after discussion with Paolo and rather
it makes more sense to keep the API as it is and to update callers where it
makes sense to.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 841D76B0069
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 04:58:18 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id d128so11491999wmf.5
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 01:58:18 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id z187si3556805wmc.63.2016.10.19.01.58.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 01:58:17 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id d199so2937390wmd.1
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 01:58:17 -0700 (PDT)
Date: Wed, 19 Oct 2016 09:58:15 +0100
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: Re: [PATCH 00/10] mm: adjust get_user_pages* functions to explicitly
 pass FOLL_* flags
Message-ID: <20161019085815.GA22239@lucifer>
References: <20161013002020.3062-1-lstoakes@gmail.com>
 <20161018153050.GC13117@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161018153050.GC13117@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, adi-buildroot-devel@lists.sourceforge.net, ceph-devel@vger.kernel.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, kvm@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-cris-kernel@axis.com, linux-fbdev@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mips@linux-mips.org, linux-rdma@vger.kernel.org, linux-s390@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org, linux-security-module@vger.kernel.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org

On Tue, Oct 18, 2016 at 05:30:50PM +0200, Michal Hocko wrote:
> I am wondering whether we can go further. E.g. it is not really clear to
> me whether we need an explicit FOLL_REMOTE when we can in fact check
> mm != current->mm and imply that. Maybe there are some contexts which
> wouldn't work, I haven't checked.

This flag is set even when /proc/self/mem is used. I've not looked deeply into
this flag but perhaps accessing your own memory this way can be considered
'remote' since you're not accessing it directly. On the other hand, perhaps this
is just mistaken in this case?

> I guess there is more work in that area and I do not want to impose all
> that work on you, but I couldn't resist once I saw you playing in that
> area ;) Definitely a good start!

Thanks, I am more than happy to go as far down this rabbit hole as is helpful,
no imposition at all :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

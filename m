Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9CFF26B0261
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 05:07:31 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id g16so11715899wmg.3
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 02:07:31 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id g77si3592690wmc.10.2016.10.19.02.07.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 02:07:30 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id d199so2971656wmd.1
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 02:07:30 -0700 (PDT)
Date: Wed, 19 Oct 2016 11:07:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 00/10] mm: adjust get_user_pages* functions to explicitly
 pass FOLL_* flags
Message-ID: <20161019090727.GE7517@dhcp22.suse.cz>
References: <20161013002020.3062-1-lstoakes@gmail.com>
 <20161018153050.GC13117@dhcp22.suse.cz>
 <20161019085815.GA22239@lucifer>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161019085815.GA22239@lucifer>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, adi-buildroot-devel@lists.sourceforge.net, ceph-devel@vger.kernel.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, kvm@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-cris-kernel@axis.com, linux-fbdev@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mips@linux-mips.org, linux-rdma@vger.kernel.org, linux-s390@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org, linux-security-module@vger.kernel.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org

On Wed 19-10-16 09:58:15, Lorenzo Stoakes wrote:
> On Tue, Oct 18, 2016 at 05:30:50PM +0200, Michal Hocko wrote:
> > I am wondering whether we can go further. E.g. it is not really clear to
> > me whether we need an explicit FOLL_REMOTE when we can in fact check
> > mm != current->mm and imply that. Maybe there are some contexts which
> > wouldn't work, I haven't checked.
> 
> This flag is set even when /proc/self/mem is used. I've not looked deeply into
> this flag but perhaps accessing your own memory this way can be considered
> 'remote' since you're not accessing it directly. On the other hand, perhaps this
> is just mistaken in this case?

My understanding of the flag is quite limited as well. All I know it is
related to protection keys and it is needed to bypass protection check.
See arch_vma_access_permitted. See also 1b2ee1266ea6 ("mm/core: Do not
enforce PKEY permissions on remote mm access").

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

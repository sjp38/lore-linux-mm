Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 19B2E6B025E
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 05:06:50 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 79so11695374wmy.7
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 02:06:50 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id u10si50899610wjj.97.2016.10.19.02.06.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 02:06:49 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id f193so2964432wmg.0
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 02:06:48 -0700 (PDT)
Date: Wed, 19 Oct 2016 10:06:46 +0100
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: Re: [PATCH 08/10] mm: replace __access_remote_vm() write parameter
 with gup_flags
Message-ID: <20161019090646.GA24243@lucifer>
References: <20161013002020.3062-1-lstoakes@gmail.com>
 <20161013002020.3062-9-lstoakes@gmail.com>
 <20161019075903.GP29967@quack2.suse.cz>
 <20161019081352.GB7562@dhcp22.suse.cz>
 <20161019084045.GA19441@lucifer>
 <20161019085204.GD7517@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161019085204.GD7517@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, adi-buildroot-devel@lists.sourceforge.net, ceph-devel@vger.kernel.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, kvm@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-cris-kernel@axis.com, linux-fbdev@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mips@linux-mips.org, linux-rdma@vger.kernel.org, linux-s390@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org, linux-security-module@vger.kernel.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org

On Wed, Oct 19, 2016 at 10:52:05AM +0200, Michal Hocko wrote:
> yes this is the desirable and expected behavior.
>
> > wonder if this is desirable behaviour or whether this ought to be limited to
> > ptrace system calls. Regardless, by making the flag more visible it makes it
> > easier to see that this is happening.
>
> mem_open already enforces PTRACE_MODE_ATTACH

Ah I missed this, that makes a lot of sense, thanks!

I still wonder whether other invocations of access_remote_vm() in fs/proc/base.c
(the principle caller of this function) need FOLL_FORCE, for example the various
calls that simply read data from other processes, so I think the point stands
about keeping this explicit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

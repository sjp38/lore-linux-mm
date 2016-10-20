Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id C23216B0069
	for <linux-mm@kvack.org>; Thu, 20 Oct 2016 15:26:49 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id h85so52938617vkc.6
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 12:26:49 -0700 (PDT)
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com. [209.85.220.169])
        by mx.google.com with ESMTPS id j74si23117957vki.115.2016.10.20.12.26.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Oct 2016 12:26:48 -0700 (PDT)
Received: by mail-qk0-f169.google.com with SMTP id z190so113481976qkc.2
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 12:26:48 -0700 (PDT)
Date: Thu, 20 Oct 2016 21:26:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 00/10] mm: adjust get_user_pages* functions to explicitly
 pass FOLL_* flags
Message-ID: <20161020192646.GC27342@dhcp22.suse.cz>
References: <20161013002020.3062-1-lstoakes@gmail.com>
 <20161018153050.GC13117@dhcp22.suse.cz>
 <20161019085815.GA22239@lucifer>
 <20161019090727.GE7517@dhcp22.suse.cz>
 <5807A427.7010200@linux.intel.com>
 <20161019170127.GN24393@dhcp22.suse.cz>
 <5807AC2B.4090208@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5807AC2B.4090208@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Lorenzo Stoakes <lstoakes@gmail.com>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, adi-buildroot-devel@lists.sourceforge.net, ceph-devel@vger.kernel.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, kvm@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-cris-kernel@axis.com, linux-fbdev@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mips@linux-mips.org, linux-rdma@vger.kernel.org, linux-s390@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org, linux-security-module@vger.kernel.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org

On Wed 19-10-16 10:23:55, Dave Hansen wrote:
> On 10/19/2016 10:01 AM, Michal Hocko wrote:
> > The question I had earlier was whether this has to be an explicit FOLL
> > flag used by g-u-p users or we can just use it internally when mm !=
> > current->mm
> 
> The reason I chose not to do that was that deferred work gets run under
> a basically random 'current'.  If we just use 'mm != current->mm', then
> the deferred work will sometimes have pkeys enforced and sometimes not,
> basically randomly.

OK, I see (async_pf_execute and ksm ). It makes more sense to me. Thanks
for the clarification.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

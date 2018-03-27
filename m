Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6D0796B0010
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 12:07:25 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id r190so490561qkc.21
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 09:07:25 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id g1si1681456qtc.426.2018.03.27.09.07.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Mar 2018 09:07:24 -0700 (PDT)
Date: Tue, 27 Mar 2018 19:07:22 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v29 1/4] mm: support reporting free page blocks
Message-ID: <20180327190635-mutt-send-email-mst@kernel.org>
References: <1522031994-7246-1-git-send-email-wei.w.wang@intel.com>
 <1522031994-7246-2-git-send-email-wei.w.wang@intel.com>
 <20180326142254.c4129c3a54ade686ee2a5e21@linux-foundation.org>
 <5AB9E377.30900@intel.com>
 <20180327063322.GW5652@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180327063322.GW5652@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Wang <wei.w.wang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, huangzhichao@huawei.com

On Tue, Mar 27, 2018 at 08:33:22AM +0200, Michal Hocko wrote:
> > > > + * The function itself might sleep so it cannot be called from atomic
> > > > + * contexts.
> > > I don't see how walk_free_mem_block() can sleep.
> > 
> > OK, it would be better to remove this sentence for the current version. But
> > I think we could probably keep it if we decide to add cond_resched() below.
> 
> The point of this sentence was to make any user aware that the function
> might sleep from the very begining rather than chase existing callers
> when we need to add cond_resched or sleep for any other reason. So I
> would rather keep it.

Let's say what it is then - "will be changed to sleep in the future".

> -- 
> Michal Hocko
> SUSE Labs

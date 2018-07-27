Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3FB866B0007
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 10:06:32 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id i8-v6so4274278qke.7
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 07:06:32 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id v18-v6si4325217qta.297.2018.07.27.07.06.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jul 2018 07:06:31 -0700 (PDT)
Date: Fri, 27 Jul 2018 17:06:27 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 0/2] virtio-balloon: some improvements
Message-ID: <20180727170605-mutt-send-email-mst@kernel.org>
References: <1532683495-31974-1-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1532683495-31974-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org

On Fri, Jul 27, 2018 at 05:24:53PM +0800, Wei Wang wrote:
> This series is split from the "Virtio-balloon: support free page
> reporting" series to make some improvements.
> 
> v1->v2 ChangeLog:
> - register the shrinker when VIRTIO_BALLOON_F_DEFLATE_ON_OOM is negotiated.
> 
> Wei Wang (2):
>   virtio-balloon: remove BUG() in init_vqs
>   virtio_balloon: replace oom notifier with shrinker

Thanks!
Given it's very late in the release cycle, I'll merge this for
the next Linux release.

>  drivers/virtio/virtio_balloon.c | 125 +++++++++++++++++++++++-----------------
>  1 file changed, 72 insertions(+), 53 deletions(-)
> 
> -- 
> 2.7.4

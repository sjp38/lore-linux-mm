Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2806B0007
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 07:29:59 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id n40-v6so5561338ote.13
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 04:29:59 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d141-v6si2548275oib.199.2018.06.15.04.29.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jun 2018 04:29:58 -0700 (PDT)
Date: Fri, 15 Jun 2018 14:29:43 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v33 0/4] Virtio-balloon: support free page reporting
Message-ID: <20180615142610-mutt-send-email-mst@kernel.org>
References: <1529037793-35521-1-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1529037793-35521-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mhocko@kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com, peterx@redhat.com

On Fri, Jun 15, 2018 at 12:43:09PM +0800, Wei Wang wrote:
>       - remove the cmd id related interface. Now host can just send a free
>         page hint command to the guest (via the host_cmd config register)
>         to start the reporting.

Here we go again. And what if reporting was already started previously?
I don't think it's a good idea to tweak the host/guest interface yet
again.

-- 
MST

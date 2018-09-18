Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 25A408E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 08:27:35 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id g36-v6so969895plb.5
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 05:27:35 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 2-v6si18545930pla.495.2018.09.18.05.27.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Sep 2018 05:27:33 -0700 (PDT)
Date: Tue, 18 Sep 2018 14:27:29 +0200
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 00/19] vmw_balloon: compaction, shrinker, 64-bit, etc.
Message-ID: <20180918122729.GA13598@kroah.com>
References: <20180918063853.198332-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180918063853.198332-1-namit@vmware.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <namit@vmware.com>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org, Xavier Deguillard <xdeguillard@vmware.com>, "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>, linux-mm@kvack.org, virtualization@lists.linux-foundation.org

On Mon, Sep 17, 2018 at 11:38:34PM -0700, Nadav Amit wrote:
> This patch-set adds the following enhancements to the VMware balloon
> driver:
> 
> 1. Balloon compaction support.
> 2. Report the number of inflated/deflated ballooned pages through vmstat.
> 3. Memory shrinker to avoid balloon over-inflation (and OOM).
> 4. Support VMs with memory limit that is greater than 16TB.
> 5. Faster and more aggressive inflation.
> 
> To support compaction we wish to use the existing infrastructure.
> However, we need to make slight adaptions for it. We add a new list
> interface to balloon-compaction, which is more generic and efficient,
> since it does not require as many IRQ save/restore operations. We leave
> the old interface that is used by the virtio balloon.
> 
> Big parts of this patch-set are cleanup and documentation. Patches 1-13
> simplify the balloon code, document its behavior and allow the balloon
> code to run concurrently. The support for concurrency is required for
> compaction and the shrinker interface.
> 
> For documentation we use the kernel-doc format. We are aware that the
> balloon interface is not public, but following the kernel-doc format may
> be useful one day.

kbuild seems to not like this patch series, so I'm going to drop it from
my queue and wait for a v2 respin before looking at it.

thanks,

greg k-h

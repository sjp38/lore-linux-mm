Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8B65C6B007E
	for <linux-mm@kvack.org>; Tue, 19 Apr 2016 10:54:40 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id x7so36086824qkd.2
        for <linux-mm@kvack.org>; Tue, 19 Apr 2016 07:54:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y126si48429492qha.49.2016.04.19.07.54.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Apr 2016 07:54:39 -0700 (PDT)
Message-ID: <1461077659.3200.8.camel@redhat.com>
Subject: Re: [PATCH kernel 1/2] mm: add the related functions to build the
 free page bitmap
From: Rik van Riel <riel@redhat.com>
Date: Tue, 19 Apr 2016 10:54:19 -0400
In-Reply-To: <1461076474-3864-2-git-send-email-liang.z.li@intel.com>
References: <1461076474-3864-1-git-send-email-liang.z.li@intel.com>
	 <1461076474-3864-2-git-send-email-liang.z.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Li <liang.z.li@intel.com>, mst@redhat.com, viro@zeniv.linux.org.uk, linux-kernel@vger.kernel.org, quintela@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, dgilbert@redhat.com
Cc: linux-mm@kvack.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, agraf@suse.de, borntraeger@de.ibm.com

On Tue, 2016-04-19 at 22:34 +0800, Liang Li wrote:
> The free page bitmap will be sent to QEMU through virtio interface
> and used for live migration optimization.
> Drop the cache before building the free page bitmap can get more
> free pages. Whether dropping the cache is decided by user.
> 

How do you prevent the guest from using those
recently-freed pages for something else, between
when you build the bitmap and the live migration
completes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id A975B6B0260
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 12:53:11 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id yx5so1769626pac.5
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 09:53:11 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id a11si16320683pgd.80.2016.10.24.09.53.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 09:53:11 -0700 (PDT)
Subject: Re: [RESEND PATCH v3 kernel 3/7] mm: add a function to get the max
 pfn
References: <1477031080-12616-1-git-send-email-liang.z.li@intel.com>
 <1477031080-12616-4-git-send-email-liang.z.li@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <580E3C76.3010205@intel.com>
Date: Mon, 24 Oct 2016 09:53:10 -0700
MIME-Version: 1.0
In-Reply-To: <1477031080-12616-4-git-send-email-liang.z.li@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Li <liang.z.li@intel.com>, mst@redhat.com
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, quintela@redhat.com, dgilbert@redhat.com, pbonzini@redhat.com, cornelia.huck@de.ibm.com, amit.shah@redhat.com, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>

On 10/20/2016 11:24 PM, Liang Li wrote:
> Expose the function to get the max pfn, so it can be used in the
> virtio-balloon device driver. Simply include the 'linux/bootmem.h'
> is not enough, if the device driver is built to a module, directly
> refer the max_pfn lead to build failed.

I'm not sure the rest of the set is worth reviewing.  I think a lot of
it will change pretty fundamentally once you have those improved data
structures in place.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

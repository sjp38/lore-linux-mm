Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 190C16B0253
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 12:46:07 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id py6so1715981pab.0
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 09:46:07 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id x86si16287410pff.54.2016.10.24.09.46.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 09:46:06 -0700 (PDT)
Subject: Re: [RESEND PATCH v3 kernel 1/7] virtio-balloon: rework deflate to
 add page to a list
References: <1477031080-12616-1-git-send-email-liang.z.li@intel.com>
 <1477031080-12616-2-git-send-email-liang.z.li@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <580E3ACD.1080906@intel.com>
Date: Mon, 24 Oct 2016 09:46:05 -0700
MIME-Version: 1.0
In-Reply-To: <1477031080-12616-2-git-send-email-liang.z.li@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Li <liang.z.li@intel.com>, mst@redhat.com
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, quintela@redhat.com, dgilbert@redhat.com, pbonzini@redhat.com, cornelia.huck@de.ibm.com, amit.shah@redhat.com

On 10/20/2016 11:24 PM, Liang Li wrote:
> Will allow faster notifications using a bitmap down the road.
> balloon_pfn_to_page() can be removed because it's useless.

This is a pretty terse description of what's going on here.  Could you
try to elaborate a bit?  What *is* the current approach?  Why does it
not work going forward?  What do you propose instead?  Why is it better?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

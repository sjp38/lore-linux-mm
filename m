Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 353486B0275
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 14:15:02 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e6so600723pfk.2
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 11:15:02 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id fc3si3295759pab.267.2016.10.26.11.15.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 11:15:01 -0700 (PDT)
Subject: Re: [RESEND PATCH v3 kernel 0/7] Extend virtio-balloon for fast
 (de)inflating & fast live migration
References: <1477031080-12616-1-git-send-email-liang.z.li@intel.com>
 <580A4F81.60201@intel.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A0FD034@shsmsx102.ccr.corp.intel.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A0FD05E@shsmsx102.ccr.corp.intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <5810F2A4.6080907@intel.com>
Date: Wed, 26 Oct 2016 11:15:00 -0700
MIME-Version: 1.0
In-Reply-To: <F2CBF3009FA73547804AE4C663CAB28E3A0FD05E@shsmsx102.ccr.corp.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Liang Z" <liang.z.li@intel.com>, "mst@redhat.com" <mst@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "quintela@redhat.com" <quintela@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>

On 10/26/2016 03:13 AM, Li, Liang Z wrote:
> 3 times memory required is not accurate, please ignore this. sorry ...
> The complexity is the point. 

What is making it so complex?  Can you describe the problems?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

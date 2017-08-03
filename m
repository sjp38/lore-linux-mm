Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6E7B3280300
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 17:02:13 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id o5so11753153qki.2
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 14:02:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x90si13666381qte.479.2017.08.03.14.02.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Aug 2017 14:02:12 -0700 (PDT)
Date: Fri, 4 Aug 2017 00:02:01 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v13 4/5] mm: support reporting free page blocks
Message-ID: <20170804000043-mutt-send-email-mst@kernel.org>
References: <20170803091151.GF12521@dhcp22.suse.cz>
 <5982FE07.3040207@intel.com>
 <20170803104417.GI12521@dhcp22.suse.cz>
 <59830897.2060203@intel.com>
 <20170803112831.GN12521@dhcp22.suse.cz>
 <5983130E.2070806@intel.com>
 <20170803124106.GR12521@dhcp22.suse.cz>
 <59832265.1040805@intel.com>
 <20170803135047.GV12521@dhcp22.suse.cz>
 <286AC319A985734F985F78AFA26841F73928C971@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <286AC319A985734F985F78AFA26841F73928C971@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Wei W" <wei.w.wang@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu@aliyun.com" <quan.xu@aliyun.com>

On Thu, Aug 03, 2017 at 03:20:09PM +0000, Wang, Wei W wrote:
> On Thursday, August 3, 2017 9:51 PM, Michal Hocko: 
> > As I've said earlier. Start simple optimize incrementally with some numbers to
> > justify a more subtle code.
> > --
> 
> OK. Let's start with the simple implementation as you suggested.
> 
> Best,
> Wei

The tricky part is when you need to drop the lock and
then restart because the device is busy. Would it maybe
make sense to rotate the list so that new head
will consist of pages not yet sent to device?

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

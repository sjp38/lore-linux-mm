Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0DB5B6B071B
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 03:53:41 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id q189so4742352wmd.6
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 00:53:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 204si2714365wmw.252.2017.08.04.00.53.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 Aug 2017 00:53:40 -0700 (PDT)
Date: Fri, 4 Aug 2017 09:53:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v13 4/5] mm: support reporting free page blocks
Message-ID: <20170804075337.GC26029@dhcp22.suse.cz>
References: <5982FE07.3040207@intel.com>
 <20170803104417.GI12521@dhcp22.suse.cz>
 <59830897.2060203@intel.com>
 <20170803112831.GN12521@dhcp22.suse.cz>
 <5983130E.2070806@intel.com>
 <20170803124106.GR12521@dhcp22.suse.cz>
 <59832265.1040805@intel.com>
 <20170803135047.GV12521@dhcp22.suse.cz>
 <286AC319A985734F985F78AFA26841F73928C971@shsmsx102.ccr.corp.intel.com>
 <20170804000043-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170804000043-mutt-send-email-mst@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "Wang, Wei W" <wei.w.wang@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu@aliyun.com" <quan.xu@aliyun.com>

On Fri 04-08-17 00:02:01, Michael S. Tsirkin wrote:
> On Thu, Aug 03, 2017 at 03:20:09PM +0000, Wang, Wei W wrote:
> > On Thursday, August 3, 2017 9:51 PM, Michal Hocko: 
> > > As I've said earlier. Start simple optimize incrementally with some numbers to
> > > justify a more subtle code.
> > > --
> > 
> > OK. Let's start with the simple implementation as you suggested.
> > 
> > Best,
> > Wei
> 
> The tricky part is when you need to drop the lock and
> then restart because the device is busy. Would it maybe
> make sense to rotate the list so that new head
> will consist of pages not yet sent to device?

No, I this should be strictly non-modifying API.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

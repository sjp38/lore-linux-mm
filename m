Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B93E26B06D3
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 11:20:15 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p20so15971026pfj.2
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 08:20:15 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id c83si21284156pfd.95.2017.08.03.08.20.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Aug 2017 08:20:14 -0700 (PDT)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [PATCH v13 4/5] mm: support reporting free page blocks
Date: Thu, 3 Aug 2017 15:20:09 +0000
Message-ID: <286AC319A985734F985F78AFA26841F73928C971@shsmsx102.ccr.corp.intel.com>
References: <1501742299-4369-1-git-send-email-wei.w.wang@intel.com>
 <1501742299-4369-5-git-send-email-wei.w.wang@intel.com>
 <20170803091151.GF12521@dhcp22.suse.cz> <5982FE07.3040207@intel.com>
 <20170803104417.GI12521@dhcp22.suse.cz> <59830897.2060203@intel.com>
 <20170803112831.GN12521@dhcp22.suse.cz> <5983130E.2070806@intel.com>
 <20170803124106.GR12521@dhcp22.suse.cz> <59832265.1040805@intel.com>
 <20170803135047.GV12521@dhcp22.suse.cz>
In-Reply-To: <20170803135047.GV12521@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mst@redhat.com" <mst@redhat.com>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu@aliyun.com" <quan.xu@aliyun.com>

On Thursday, August 3, 2017 9:51 PM, Michal Hocko:=20
> As I've said earlier. Start simple optimize incrementally with some numbe=
rs to
> justify a more subtle code.
> --

OK. Let's start with the simple implementation as you suggested.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

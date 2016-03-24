Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id A96CD6B0005
	for <linux-mm@kvack.org>; Thu, 24 Mar 2016 19:23:30 -0400 (EDT)
Received: by mail-pf0-f170.google.com with SMTP id 4so69408143pfd.0
        for <linux-mm@kvack.org>; Thu, 24 Mar 2016 16:23:30 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id m17si15053309pfj.147.2016.03.24.16.23.28
        for <linux-mm@kvack.org>;
        Thu, 24 Mar 2016 16:23:28 -0700 (PDT)
From: "Verma, Vishal L" <vishal.l.verma@intel.com>
Subject: Re: [PATCH 3/5] dax: enable dax in the presence of known media
 errors (badblocks)
Date: Thu, 24 Mar 2016 23:23:26 +0000
Message-ID: <1458861805.7619.1.camel@intel.com>
References: <1458861450-17705-1-git-send-email-vishal.l.verma@intel.com>
	 <1458861450-17705-4-git-send-email-vishal.l.verma@intel.com>
In-Reply-To: <1458861450-17705-4-git-send-email-vishal.l.verma@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <A001440F8D6C3C4CB24CFB5EC465E195@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>
Cc: "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "axboe@fb.com" <axboe@fb.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "david@fromorbit.com" <david@fromorbit.com>, "jack@suse.cz" <jack@suse.cz>

T24gVGh1LCAyMDE2LTAzLTI0IGF0IDE3OjE3IC0wNjAwLCBWaXNoYWwgVmVybWEgd3JvdGU6DQo+
IEZyb206IERhbiBXaWxsaWFtcyA8ZGFuLmoud2lsbGlhbXNAaW50ZWwuY29tPg0KPiANCj4gRnJv
bTogRGFuIFdpbGxpYW1zIDxkYW4uai53aWxsaWFtc0BpbnRlbC5jb20+DQoNCkVlcCwgbm90IHN1
cmUgaG93IHRoaXMgaGFwcGVuZWQsIGxvb2tlZCBhbHJpZ2h0IGluIHRoZSBwYXRjaGVzIQ==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

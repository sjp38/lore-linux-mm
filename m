Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id DCE996B0005
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 14:57:41 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id td3so20685640pab.2
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 11:57:41 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id r72si100152pfb.235.2016.03.29.11.57.40
        for <linux-mm@kvack.org>;
        Tue, 29 Mar 2016 11:57:40 -0700 (PDT)
From: "Verma, Vishal L" <vishal.l.verma@intel.com>
Subject: Re: [PATCH 4/5] dax: use sb_issue_zerout instead of calling
 dax_clear_sectors
Date: Tue, 29 Mar 2016 18:57:16 +0000
Message-ID: <1459277829.6412.3.camel@intel.com>
References: <1458861450-17705-1-git-send-email-vishal.l.verma@intel.com>
	 <1458861450-17705-5-git-send-email-vishal.l.verma@intel.com>
	 <CAPcyv4iKK=1Nhz4QqEkhc4gum+UvUS4a=+Sza2zSa1Kyrth41w@mail.gmail.com>
	 <1458939796.5501.8.camel@intel.com>
	 <CAPcyv4jWqVcav7dQPh7WHpqB6QDrCezO5jbd9QW9xH3zsU4C1w@mail.gmail.com>
	 <1459195288.15523.3.camel@intel.com>
	 <CAPcyv4jFwh679arTNoUzLZpJCSoR+KhMdEmwqddCU1RWOrjD=Q@mail.gmail.com>
In-Reply-To: <CAPcyv4jFwh679arTNoUzLZpJCSoR+KhMdEmwqddCU1RWOrjD=Q@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <64C5EAC5F614C94A96594C71EC7AFD03@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Williams, Dan J" <dan.j.williams@intel.com>
Cc: "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "axboe@fb.com" <axboe@fb.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "david@fromorbit.com" <david@fromorbit.com>, "jack@suse.cz" <jack@suse.cz>

T24gTW9uLCAyMDE2LTAzLTI4IGF0IDE2OjM0IC0wNzAwLCBEYW4gV2lsbGlhbXMgd3JvdGU6DQoN
Cjw+DQoNCj4gU2VlbXMga2luZCBvZiBzYWQgdG8gZmFpbCB0aGUgZmF1bHQgZHVlIHRvIGEgYmFk
IGJsb2NrIHdoZW4gd2Ugd2VyZQ0KPiBnb2luZyB0byB6ZXJvIGl0IGFueXdheSwgcmlnaHQ/wqDC
oEknbSBub3Qgc2VlaW5nIGEgY29tcGVsbGluZyByZWFzb24gdG8NCj4ga2VlcCBhbnkgemVyb2lu
ZyBpbiBmcy9kYXguYy4NCg0KQWdyZWVkIC0gYnV0IGhvdyBkbyB3ZSBkbyB0aGlzPyBjbGVhcl9w
bWVtIG5lZWRzIHRvIGJlIGFibGUgdG8gY2xlYXIgYW4NCmFyYml0cmFyeSBudW1iZXIgb2YgYnl0
ZXMsIGJ1dCB0byBnbyB0aHJvdWdoIHRoZSBkcml2ZXIsIHdlJ2QgbmVlZCB0bw0Kc2VuZCBkb3du
IGEgYmlvPyBJZiBvbmx5IHRoZSBkcml2ZXIgaGFkIGFuIHJ3X2J5dGVzIGxpa2UgaW50ZXJmYWNl
IHRoYXQNCmNvdWxkIGJlIHVzZWQgYnkgYW55b25lLi4uIDop

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

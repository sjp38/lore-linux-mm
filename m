Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id EB5A56B0253
	for <linux-mm@kvack.org>; Wed, 11 May 2016 14:40:01 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 4so101048737pfw.0
        for <linux-mm@kvack.org>; Wed, 11 May 2016 11:40:01 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id in12si11423580pac.224.2016.05.11.11.40.00
        for <linux-mm@kvack.org>;
        Wed, 11 May 2016 11:40:01 -0700 (PDT)
From: "Verma, Vishal L" <vishal.l.verma@intel.com>
Subject: Re: [PATCH v6 4/5] dax: for truncate/hole-punch, do zeroing through
 the driver if possible
Date: Wed, 11 May 2016 18:39:59 +0000
Message-ID: <1462991986.29294.29.camel@intel.com>
References: <1462906156-22303-1-git-send-email-vishal.l.verma@intel.com>
	 <1462906156-22303-5-git-send-email-vishal.l.verma@intel.com>
In-Reply-To: <1462906156-22303-5-git-send-email-vishal.l.verma@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <5E1FB0B45FA4AB4A819E9443201F1C82@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "hch@infradead.org" <hch@infradead.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "jmoyer@redhat.com" <jmoyer@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "axboe@fb.com" <axboe@fb.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "boaz@plexistor.com" <boaz@plexistor.com>, "david@fromorbit.com" <david@fromorbit.com>, "jack@suse.cz" <jack@suse.cz>

T24gVHVlLCAyMDE2LTA1LTEwIGF0IDEyOjQ5IC0wNjAwLCBWaXNoYWwgVmVybWEgd3JvdGU6DQo+
wqANCi4uLg0KDQo+IEBAIC0xMjQwLDExICsxMjU0LDE2IEBAIGludCBkYXhfemVyb19wYWdlX3Jh
bmdlKHN0cnVjdCBpbm9kZSAqaW5vZGUsDQo+IGxvZmZfdCBmcm9tLCB1bnNpZ25lZCBsZW5ndGgs
DQo+IMKgCQkJLnNpemUgPSBQQUdFX1NJWkUsDQo+IMKgCQl9Ow0KPiDCoA0KPiAtCQlpZiAoZGF4
X21hcF9hdG9taWMoYmRldiwgJmRheCkgPCAwKQ0KPiAtCQkJcmV0dXJuIFBUUl9FUlIoZGF4LmFk
ZHIpOw0KPiAtCQljbGVhcl9wbWVtKGRheC5hZGRyICsgb2Zmc2V0LCBsZW5ndGgpOw0KPiAtCQl3
bWJfcG1lbSgpOw0KPiAtCQlkYXhfdW5tYXBfYXRvbWljKGJkZXYsICZkYXgpOw0KPiArCQlpZiAo
ZGF4X3JhbmdlX2lzX2FsaWduZWQoYmRldiwgJmRheCwgb2Zmc2V0LCBsZW5ndGgpKQ0KPiArCQkJ
cmV0dXJuIGJsa2Rldl9pc3N1ZV96ZXJvb3V0KGJkZXYsIGRheC5zZWN0b3IsDQo+ICsJCQkJCWxl
bmd0aCA+PiA5LCBHRlBfTk9GUywgdHJ1ZSk7DQoNCkZvdW5kIGFub3RoZXIgYnVnIGhlcmUgd2hp
bGUgdGVzdGluZy4gVGhlIHplcm9vdXQgbmVlZHMgdG8gYmUgZG9uZSBmb3INCnNlY3RvciArIChv
ZmZzZXQgPj4gOSkuIFRoZSBhYm92ZSBqdXN0IHplcm9lZCBvdXQgdGhlIGZpcnN0IHNlY3RvciBv
Zg0KdGhlIHBhZ2UgaXJyZXNwZWN0aXZlIG9mIG9mZnNldCwgd2hpY2ggaXMgd3Jvbmcu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

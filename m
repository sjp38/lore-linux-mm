Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 9041B6B007E
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 16:44:10 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id zm5so20597270pac.0
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 13:44:10 -0700 (PDT)
Received: from smtp-outbound-2.vmware.com (smtp-outbound-2.vmware.com. [208.91.2.13])
        by mx.google.com with ESMTPS id v18si1369566pfi.211.2016.03.28.13.44.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Mar 2016 13:44:09 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: Re: [PATCH v2 1/2] x86/mm: TLB_REMOTE_SEND_IPI should count pages
Date: Mon, 28 Mar 2016 20:44:07 +0000
Message-ID: <64432900-43CA-4D72-A041-44B0F40DBE88@vmware.com>
References: <1458980705-121507-1-git-send-email-namit@vmware.com>
 <1458980705-121507-2-git-send-email-namit@vmware.com>
 <20160328133825.210d00fd4af7c7b7039a44c7@linux-foundation.org>
In-Reply-To: <20160328133825.210d00fd4af7c7b7039a44c7@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <AC3392959FB12846BD22380634CC4C0D@vmware.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, "mgorman@suse.de" <mgorman@suse.de>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "riel@redhat.com" <riel@redhat.com>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "luto@kernel.org" <luto@kernel.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "jmarchan@redhat.com" <jmarchan@redhat.com>, "hughd@google.com" <hughd@google.com>, "vdavydov@virtuozzo.com" <vdavydov@virtuozzo.com>, "minchan@kernel.org" <minchan@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

T24gMy8yOC8xNiwgMTozOCBQTSwgIkFuZHJldyBNb3J0b24iIDxha3BtQGxpbnV4LWZvdW5kYXRp
b24ub3JnPiB3cm90ZToNCg0KDQo+T24gU2F0LCAyNiBNYXIgMjAxNiAwMToyNTowNCAtMDcwMCBO
YWRhdiBBbWl0IDxuYW1pdEB2bXdhcmUuY29tPiB3cm90ZToNCj4NCj4+IFRMQl9SRU1PVEVfU0VO
RF9JUEkgd2FzIHJlY2VudGx5IGludHJvZHVjZWQsIGJ1dCBpdCBjb3VudHMgYnl0ZXMgaW5zdGVh
ZA0KPj4gb2YgcGFnZXMuIEluIGFkZGl0aW9uLCBpdCBkb2VzIG5vdCByZXBvcnQgY29ycmVjdGx5
IHRoZSBjYXNlIGluIHdoaWNoDQo+PiBmbHVzaF90bGJfcGFnZSBmbHVzaGVzIGEgcGFnZS4gRml4
IGl0IHRvIGJlIGNvbnNpc3RlbnQgd2l0aCBvdGhlciBUTEINCj4+IGNvdW50ZXJzLg0KPj4gDQo+
PiBGaXhlczogNDU5NWY5NjIwY2RhOGExZTk3MzU4OGU3NDNjZjVmODQzNmRkMjBjNg0KPg0KPkkg
dGhpbmsgeW91IG1lYW4gNWI3NDI4M2FiMjUxYjkgKCJ4ODYsIG1tOiB0cmFjZSB3aGVuIGFuIElQ
SSBpcyBhYm91dA0KPnRvIGJlIHNlbnQiKT8NCg0KSW5kZWVkLg0KDQoNCg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

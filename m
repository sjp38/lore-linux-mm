Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8C1F86B0431
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 11:34:08 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id q197so236556395oic.7
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 08:34:08 -0800 (PST)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0090.outbound.protection.outlook.com. [104.47.34.90])
        by mx.google.com with ESMTPS id y30si3479027oty.52.2016.11.18.08.34.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 18 Nov 2016 08:34:07 -0800 (PST)
From: Matthew Wilcox <mawilcox@microsoft.com>
Subject: RE: [PATCH 21/29] radix-tree: Delete radix_tree_locate_item()
Date: Fri, 18 Nov 2016 16:34:05 +0000
Message-ID: <SN1PR21MB00771B7E1F66DE0A62F2FDD7CBB00@SN1PR21MB0077.namprd21.prod.outlook.com>
References: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
 <1479341856-30320-60-git-send-email-mawilcox@linuxonhyperv.com>
 <CALYGNiObc5zm8TQ9xTzwpBJRvOrgeMVkQM5wxges=9TsSj9Msg@mail.gmail.com>
In-Reply-To: <CALYGNiObc5zm8TQ9xTzwpBJRvOrgeMVkQM5wxges=9TsSj9Msg@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>, Matthew Wilcox <mawilcox@linuxonhyperv.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

RnJvbTogS29uc3RhbnRpbiBLaGxlYm5pa292IFttYWlsdG86a29jdDlpQGdtYWlsLmNvbV0NCj4g
T24gVGh1LCBOb3YgMTcsIDIwMTYgYXQgMzoxNyBBTSwgTWF0dGhldyBXaWxjb3gNCj4gPG1hd2ls
Y294QGxpbnV4b25oeXBlcnYuY29tPiB3cm90ZToNCj4gPiBUaGlzIHJhdGhlciBjb21wbGljYXRl
ZCBmdW5jdGlvbiBjYW4gYmUgYmV0dGVyIGltcGxlbWVudGVkIGFzIGFuIGl0ZXJhdG9yLg0KPiA+
IEl0IGhhcyBvbmx5IG9uZSBjYWxsZXIsIHNvIG1vdmUgdGhlIGZ1bmN0aW9uYWxpdHkgdG8gdGhl
IG9ubHkgcGxhY2UgdGhhdA0KPiA+IG5lZWRzIGl0LiAgVXBkYXRlIHRoZSB0ZXN0IHN1aXRlIHRv
IGZvbGxvdyB0aGUgc2FtZSBwYXR0ZXJuLg0KPiANCj4gTG9va3MgZ29vZC4gSSBzdXBwb3NlIHRo
aXMgcGF0Y2ggY291bGQgYmUgYXBwbGllZCBzZXBhcmF0ZWx5Lg0KDQpZZXMsIGEgbnVtYmVyIG9m
IHRoZXNlIHBhdGNoZXMgc3RhbmQgYWxvbmUgZnJvbSBlYWNoIG90aGVyIGFuZCBjb3VsZCBlYXNp
bHkgYmUgc2VwYXJhdGVkIG91dC4NCkknbSBnb2luZyB0byBwdXQgeW91ciBSZXZpZXdlZC1ieTog
b24gdGhlIHBhdGNoZXMgeW91J3ZlIHNhaWQgIkxvb2tzIGdvb2QiIHRvLiAgVGhhbmtzIQ0KDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

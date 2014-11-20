Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id D887F6B0071
	for <linux-mm@kvack.org>; Thu, 20 Nov 2014 05:39:45 -0500 (EST)
Received: by mail-wg0-f45.google.com with SMTP id b13so3302381wgh.32
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 02:39:45 -0800 (PST)
Received: from mx0.aculab.com (mx0.aculab.com. [213.249.233.131])
        by mx.google.com with SMTP id fb7si6749204wid.47.2014.11.20.02.39.45
        for <linux-mm@kvack.org>;
        Thu, 20 Nov 2014 02:39:45 -0800 (PST)
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 11609-07 for <linux-mm@kvack.org>; Thu, 20 Nov 2014 10:39:35 +0000 (GMT)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 03/10] mm: Convert p[te|md]_numa users to
 p[te|md]_protnone_numa
Date: Thu, 20 Nov 2014 10:38:56 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1C9F48CB@AcuExch.aculab.com>
References: <1416478790-27522-1-git-send-email-mgorman@suse.de>
 <1416478790-27522-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1416478790-27522-4-git-send-email-mgorman@suse.de>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mel Gorman' <mgorman@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linux-MM <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Paul Mackerras <paulus@samba.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Sasha
 Levin <sasha.levin@oracle.com>, Dave Jones <davej@redhat.com>, LinuxPPC-dev <linuxppc-dev@lists.ozlabs.org>, Kirill Shutemov <kirill.shutemov@linux.intel.com>

RnJvbTogIE1lbCBHb3JtYW4NCj4gQ29udmVydCBleGlzdGluZyB1c2VycyBvZiBwdGVfbnVtYSBh
bmQgZnJpZW5kcyB0byB0aGUgbmV3IGhlbHBlci4gTm90ZQ0KPiB0aGF0IHRoZSBrZXJuZWwgaXMg
YnJva2VuIGFmdGVyIHRoaXMgcGF0Y2ggaXMgYXBwbGllZCB1bnRpbCB0aGUgb3RoZXINCj4gcGFn
ZSB0YWJsZSBtb2RpZmllcnMgYXJlIGFsc28gYWx0ZXJlZC4gVGhpcyBwYXRjaCBsYXlvdXQgaXMg
dG8gbWFrZQ0KPiByZXZpZXcgZWFzaWVyLg0KDQpEb2Vzbid0IHRoYXQgYnJlYWsgYmlzZWN0aW9u
Pw0KDQoJRGF2aWQNCg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

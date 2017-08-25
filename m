Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 05CA96810D7
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 18:03:04 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t3so6202409pgt.8
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 15:03:03 -0700 (PDT)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0076.outbound.protection.outlook.com. [104.47.32.76])
        by mx.google.com with ESMTPS id f3si5705708pld.670.2017.08.25.15.03.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 25 Aug 2017 15:03:03 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: Re: + mm-madvise-fix-freeing-of-locked-page-with-madv_free.patch
 added to -mm tree
Date: Fri, 25 Aug 2017 22:02:57 +0000
Message-ID: <81C11D6F-653D-4B14-A3A6-E6BB6FB5436D@vmware.com>
References: <599df681.NreP1dR3/HGSfpCe%akpm@linux-foundation.org>
 <20170824060957.GA29811@dhcp22.suse.cz>
In-Reply-To: <20170824060957.GA29811@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <A7EB48871D43404D990CA67E13EE26EF@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>, "ebiggers@google.com" <ebiggers@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, "rientjes@google.com" <rientjes@google.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, "open list:MEMORY
 MANAGEMENT" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, "nyc@holomorphy.com" <nyc@holomorphy.com>

TWljaGFsIEhvY2tvIDxtaG9ja29Aa2VybmVsLm9yZz4gd3JvdGU6DQoNCj4gSG1tLCBJIGRvIG5v
dCBzZWUgdGhpcyBuZWl0aGVyIGluIGxpbnV4LW1tIG5vciBMS01MLiBTdHJhbmdlDQo+IA0KPiBP
biBXZWQgMjMtMDgtMTcgMTQ6NDE6MjEsIEFuZHJldyBNb3J0b24gd3JvdGU6DQo+PiBGcm9tOiBF
cmljIEJpZ2dlcnMgPGViaWdnZXJzQGdvb2dsZS5jb20+DQo+PiBTdWJqZWN0OiBtbS9tYWR2aXNl
LmM6IGZpeCBmcmVlaW5nIG9mIGxvY2tlZCBwYWdlIHdpdGggTUFEVl9GUkVFDQo+PiANCj4+IElm
IG1hZHZpc2UoLi4uLCBNQURWX0ZSRUUpIHNwbGl0IGEgdHJhbnNwYXJlbnQgaHVnZXBhZ2UsIGl0
IGNhbGxlZA0KPj4gcHV0X3BhZ2UoKSBiZWZvcmUgdW5sb2NrX3BhZ2UoKS4gIFRoaXMgd2FzIHdy
b25nIGJlY2F1c2UgcHV0X3BhZ2UoKSBjYW4NCj4+IGZyZWUgdGhlIHBhZ2UsIGUuZy4gIGlmIGEg
Y29uY3VycmVudCBtYWR2aXNlKC4uLiwgTUFEVl9ET05UTkVFRCkgaGFzDQo+PiByZW1vdmVkIGl0
IGZyb20gdGhlIG1lbW9yeSBtYXBwaW5nLiAgcHV0X3BhZ2UoKSB0aGVuIHJpZ2h0ZnVsbHkgY29t
cGxhaW5lZA0KPj4gYWJvdXQgZnJlZWluZyBhIGxvY2tlZCBwYWdlLg0KPj4gDQo+PiBGaXggdGhp
cyBieSBtb3ZpbmcgdGhlIHVubG9ja19wYWdlKCkgYmVmb3JlIHB1dF9wYWdlKCkuDQoNClF1aWNr
IGdyZXAgc2hvd3MgdGhhdCBhIHNpbWlsYXIgZmxvdyAocHV0X3BhZ2UoKSBmb2xsb3dlZCBieSBh
bg0KdW5sb2NrX3BhZ2UoKSApIGFsc28gaGFwcGVucyBpbiBodWdldGxiZnNfZmFsbG9jYXRlKCku
IElzbuKAmXQgaXQgYSBwcm9ibGVtIGFzDQp3ZWxsPw0KDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

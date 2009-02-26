Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0D63F6B003D
	for <linux-mm@kvack.org>; Thu, 26 Feb 2009 04:26:31 -0500 (EST)
Received: by bwz18 with SMTP id 18so430648bwz.38
        for <linux-mm@kvack.org>; Thu, 26 Feb 2009 01:26:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1235639427.11390.11.camel@minggr>
References: <1235477835-14500-1-git-send-email-mel@csn.ul.ie>
	 <1235639427.11390.11.camel@minggr>
Date: Thu, 26 Feb 2009 11:26:29 +0200
Message-ID: <84144f020902260126g589be187j5c5f52e1d8e13abf@mail.gmail.com>
Subject: Re: [RFC PATCH 00/19] Cleanup and optimise the page allocator V2
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
To: Lin Ming <ming.m.lin@intel.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

T24gVGh1LCBGZWIgMjYsIDIwMDkgYXQgMTE6MTAgQU0sIExpbiBNaW5nIDxtaW5nLm0ubGluQGlu
dGVsLmNvbT4gd3JvdGU6Cj4gV2UgdGVzdGVkIHRoaXMgdjIgcGF0Y2ggc2VyaWVzIHdpdGggMi42
LjI5LXJjNiBvbiBkaWZmZXJlbnQgbWFjaGluZXMuCgpXaGF0IC5jb25maWcgaXMgdGhpcz8gU3Bl
Y2lmaWNhbGx5LCBpcyBTTFVCIG9yIFNMQUIgdXNlZCBoZXJlPwoKPgo+IKAgoCCgIKAgoCCgIKAg
oDRQIHF1YWwtY29yZSCgIKAyUCBxdWFsLWNvcmUgoCCgMlAgcXVhbC1jb3JlIEhUCj4goCCgIKAg
oCCgIKAgoCCgdGlnZXJ0b24goCCgIKAgoHN0b2NrbGV5IKAgoCCgIKBOZWhhbGVtCj4goCCgIKAg
oCCgIKAgoCCgLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
Cj4gdGJlbmNoIKAgoCCgIKAgoCszJSCgIKAgoCCgIKAgoCArMiUgoCCgIKAgoCCgIKAgMCUKPiBv
bHRwIKAgoCCgIKAgoCCgLTIlIKAgoCCgIKAgoCCgIDAlIKAgoCCgIKAgoCCgIKAwJQo+IGFpbTcg
oCCgIKAgoCCgIKAwJSCgIKAgoCCgIKAgoCCgMCUgoCCgIKAgoCCgIKAgoDAlCj4gc3BlY2piYjIw
MDUgoCCgICszJSCgIKAgoCCgIKAgoCAwJSCgIKAgoCCgIKAgoCCgMCUKPiBoYWNrYmVuY2ggoCCg
IKAgMCUgoCCgIKAgoCCgIKAgoDAlIKAgoCCgIKAgoCCgIKAwJQo+Cj4gbmV0cGVyZjoKPiBUQ1At
Uy0xMTJrIKAgoCCgMCUgoCCgIKAgoCCgIKAgoC0xJSCgIKAgoCCgIKAgoCAwJQo+IFRDUC1TLTY0
ayCgIKAgoCAwJSCgIKAgoCCgIKAgoCCgLTElIKAgoCCgIKAgoCCgICsxJQo+IFRDUC1SUi0xIKAg
oCCgIKAwJSCgIKAgoCCgIKAgoCCgMCUgoCCgIKAgoCCgIKAgoCsxJQo+IFVEUC1VLTRrIKAgoCCg
IKAtMiUgoCCgIKAgoCCgIKAgMCUgoCCgIKAgoCCgIKAgoC0yJQo+IFVEUC1VLTFrIKAgoCCgIKAr
MyUgoCCgIKAgoCCgIKAgMCUgoCCgIKAgoCCgIKAgoDAlCj4gVURQLVJSLTEgoCCgIKAgoDAlIKAg
oCCgIKAgoCCgIKAwJSCgIKAgoCCgIKAgoCCgMCUKPiBVRFAtUlItNTEyIKAgoCCgLTElIKAgoCCg
IKAgoCCgIDAlIKAgoCCgIKAgoCCgIKArMSUK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

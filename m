Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7898B6B027A
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 20:56:01 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id 135-v6so1974291yww.14
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 17:56:01 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id u83-v6si3444366ybb.167.2018.10.09.17.56.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 17:56:00 -0700 (PDT)
From: Rik van Riel <riel@fb.com>
Subject: Re: [PATCH 2/4] mm: workingset: use cheaper __inc_lruvec_state in
 irqsafe node reclaim
Date: Wed, 10 Oct 2018 00:55:56 +0000
Message-ID: <9b7bafe74ca551c19c5470294a33ab5f9e8905f4.camel@fb.com>
References: <20181009184732.762-1-hannes@cmpxchg.org>
	 <20181009184732.762-3-hannes@cmpxchg.org>
In-Reply-To: <20181009184732.762-3-hannes@cmpxchg.org>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <C7B1BE1BA1550D419B44172FB5F43B17@namprd15.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>

T24gVHVlLCAyMDE4LTEwLTA5IGF0IDE0OjQ3IC0wNDAwLCBKb2hhbm5lcyBXZWluZXIgd3JvdGU6
DQo+IE5vIG5lZWQgdG8gdXNlIHRoZSBwcmVlbXB0aW9uLXNhZmUgbHJ1dmVjIHN0YXRlIGZ1bmN0
aW9uIGluc2lkZSB0aGUNCj4gcmVjbGFpbSByZWdpb24gdGhhdCBoYXMgaXJxcyBkaXNhYmxlZC4N
Cj4gDQo+IFNpZ25lZC1vZmYtYnk6IEpvaGFubmVzIFdlaW5lciA8aGFubmVzQGNtcHhjaGcub3Jn
Pg0KDQpSZXZpZXdlZC1ieTogUmlrIHZhbiBSaWVsIDxyaWVsQHN1cnJpZWwuY29tPg0KDQo=

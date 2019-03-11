Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64C86C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 16:41:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B75A206BA
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 16:41:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B75A206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ab.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 949B08E0004; Mon, 11 Mar 2019 12:41:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8FA768E0002; Mon, 11 Mar 2019 12:41:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 811418E0004; Mon, 11 Mar 2019 12:41:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 416598E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 12:41:38 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d5so6760884pfo.5
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 09:41:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language
         :content-transfer-encoding:mime-version;
        bh=fnauwpiyHfCaAOrn/MRsXZZyJI9YPGVba5U55engSpA=;
        b=cV1QH282hzNeYh7XgTqOJ+tOsm4+sfh2ikRXEKe1mIt7pU2g9NqfomqozoNVh4/5ar
         2ix3YXxn1tJUUxzToHpK3IG2Nkg1tiEgR4MJSGtG+3exHEvVv1S+PZkuRuCGkklW1pVy
         IeUHzi4T5S5nD0QIyuNzP45QC+qcwFfXaNpmyh41lmPVFlHlV9ZEf3W7GwGdbvrJnvtK
         +FdGpseHu9nYjomLdsO/7dXA7Qi/w4KZ5CNEhKMlz+GW1vcGJEJOLmFfi1b0GAR42DE8
         QPstGL+HEKlBOmPhRAH/2Ng5XGdcIUrVI8by4xcPQxRxMHWcbKsVzShcjMvmClElYvmG
         uROg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of k-hagio@ab.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=k-hagio@ab.jp.nec.com
X-Gm-Message-State: APjAAAWXzTv7FJde6gl/t+cxuFE8QNnPDV6sztw1U51xNTzEhfcU5cdJ
	LGKGrJQI1stKRjYa1hNcSZPl3Mi+ZQNPfJlwWQOXy8XclpfzIOSWSNnvFTI/B9Zznv26QjzO2/Y
	lV91ofAK3xN6JrOPD6N/mQ3GXG5n0f9ihbJwnffFYuHUsIIRIP45MbZRY/2H0HUPkrA==
X-Received: by 2002:a62:b286:: with SMTP id z6mr33882630pfl.106.1552322497924;
        Mon, 11 Mar 2019 09:41:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxcbB5LTO4wxzMHDDQpYhcojBr4ekZO4lvpa8WVrFi8oGtjzzKaVPGWp3DfWKIdyQt7hXFb
X-Received: by 2002:a62:b286:: with SMTP id z6mr33882554pfl.106.1552322497038;
        Mon, 11 Mar 2019 09:41:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552322497; cv=none;
        d=google.com; s=arc-20160816;
        b=DvPCwkQss7weIGdibb40C3bkhE1Z1zreWuuso2Pf1b0AlksxN4DOWYQQfUz8xoncAp
         kq1nIHPSAHA/38DkwEMYDiAbC8vKpDBx7YdjD1BdC3BzXIqllMQmBLvKrc1WlYbxXboN
         Vv48UwV+4b5P05+WEjuFRNEGbiwb22kvVX5hZ+i9WghPK6W4wmFWUAgsyCD13kN6AbBp
         DA7FxO0y7KQoWdJFYmpNAS9Dv2MD0+gM68x/C2ZVIo2LYVnKTtS3jfG2HRUOzH8NyjG1
         hODQBdpcSfLuRR1PsTHzzg8r69mYbN8o0MT+XWEbhtlOTGz12JztgBswJUcwJeDCsuCj
         g6bQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=fnauwpiyHfCaAOrn/MRsXZZyJI9YPGVba5U55engSpA=;
        b=rOdWUmsDZ/kprqebdq/uNaISQ+0Lr2kmgrtQDToknJUPmsESGe0DPrdbI61VbrGNXZ
         qaT7J4nkNmojD0e9DvWj/xaS9cx4DhYCwI0UDet0QFOrxtQwWnxvPq9B2DhstObvUiWN
         TphkoZ4hsZTChT3t5w634XG293JKVxBX4RNPCfLTWmbgi/T/ZDXdGTbgZOvknUSnihIT
         SCsWo/5Q4v6G4A7av9dC491vUAuUOM2JLcNJ41O4OI66Cbnm/t7fdKdzhfCF7cSrh60D
         Y1HeT93aEDJuk0tL665SM0xb4C+cDaiNzVAJxNoXdUkbWPR5Ud0Y0cndbL8Dn+iP8rFF
         VHcw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of k-hagio@ab.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=k-hagio@ab.jp.nec.com
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id r7si5382419pgi.20.2019.03.11.09.41.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 09:41:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of k-hagio@ab.jp.nec.com designates 114.179.232.162 as permitted sender) client-ip=114.179.232.162;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of k-hagio@ab.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=k-hagio@ab.jp.nec.com
Received: from mailgate02.nec.co.jp ([114.179.233.122])
	by tyo162.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x2BGfZmN001941
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Tue, 12 Mar 2019 01:41:35 +0900
Received: from mailsv01.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x2BGfZUk021195;
	Tue, 12 Mar 2019 01:41:35 +0900
Received: from mail02.kamome.nec.co.jp (mail02.kamome.nec.co.jp [10.25.43.5])
	by mailsv01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x2BGfZVb010851;
	Tue, 12 Mar 2019 01:41:35 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.138] [10.38.151.138]) by mail01b.kamome.nec.co.jp with ESMTP id BT-MMP-3232926; Tue, 12 Mar 2019 01:40:32 +0900
Received: from BPXM09GP.gisp.nec.co.jp ([10.38.151.201]) by
 BPXC10GP.gisp.nec.co.jp ([10.38.151.138]) with mapi id 14.03.0319.002; Tue,
 12 Mar 2019 01:40:31 +0900
From: Kazuhito Hagio <k-hagio@ab.jp.nec.com>
To: David Hildenbrand <david@redhat.com>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
        "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>,
        "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
        kexec-ml <kexec@lists.infradead.org>,
        "pv-drivers@vmware.com" <pv-drivers@vmware.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: RE: [PATCH v2] makedumpfile: exclude pages that are logically
 offline
Thread-Topic: [PATCH v2] makedumpfile: exclude pages that are logically
 offline
Thread-Index: AQHUgkt9RCAzPwtH6E+Mr2lxoeU83qVig1dAgJ1kP4CAB2P8UA==
Date: Mon, 11 Mar 2019 16:40:30 +0000
Message-ID: <4AE2DC15AC0B8543882A74EA0D43DBEC03569C9C@BPXM09GP.gisp.nec.co.jp>
References: <20181122100627.5189-1-david@redhat.com>
 <20181122100938.5567-1-david@redhat.com>
 <4AE2DC15AC0B8543882A74EA0D43DBEC03561800@BPXM09GP.gisp.nec.co.jp>
 <7c9d6d5c-d6cf-00a7-7f23-bf28cbb382af@redhat.com>
In-Reply-To: <7c9d6d5c-d6cf-00a7-7f23-bf28cbb382af@redhat.com>
Accept-Language: ja-JP, en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [143.101.135.136]
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

LS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCj4gT24gMjcuMTEuMTggMTc6MzIsIEthenVoaXRv
IEhhZ2lvIHdyb3RlOg0KPiA+PiBMaW51eCBtYXJrcyBwYWdlcyB0aGF0IGFyZSBsb2dpY2FsbHkg
b2ZmbGluZSB2aWEgYSBwYWdlIGZsYWcgKG1hcCBjb3VudCkuDQo+ID4+IFN1Y2ggcGFnZXMgZS5n
LiBpbmNsdWRlIHBhZ2VzIGluZmF0ZWQgYXMgcGFydCBvZiBhIGJhbGxvb24gZHJpdmVyIG9yDQo+
ID4+IHBhZ2VzIHRoYXQgd2VyZSBub3QgYWN0dWFsbHkgb25saW5lZCB3aGVuIG9ubGluaW5nIHRo
ZSB3aG9sZSBzZWN0aW9uLg0KPiA+Pg0KPiA+PiBXaGlsZSB0aGUgaHlwZXJ2aXNvciB1c3VhbGx5
IGFsbG93cyB0byByZWFkIHN1Y2ggaW5mbGF0ZWQgbWVtb3J5LCB3ZQ0KPiA+PiBiYXNpY2FsbHkg
cmVhZCBhbmQgZHVtcCBkYXRhIHRoYXQgaXMgY29tcGxldGVseSBpcnJlbGV2YW50LiBBbHNvLCB0
aGlzDQo+ID4+IG1pZ2h0IHJlc3VsdCBpbiBxdWl0ZSBzb21lIG92ZXJoZWFkIGluIHRoZSBoeXBl
cnZpc29yLiBJbiBhZGRpdGlvbiwNCj4gPj4gd2Ugc2F3IHNvbWUgcHJvYmxlbXMgdW5kZXIgSHlw
ZXItViwgd2hlcmVieSB3ZSBjYW4gY3Jhc2ggdGhlIGtlcm5lbCBieQ0KPiA+PiBkdW1waW5nLCB3
aGVuIHJlYWRpbmcgbWVtb3J5IG9mIGEgcGFydGlhbGx5IG9ubGluZWQgbWVtb3J5IHNlZ21lbnQN
Cj4gPj4gKGZvciBtZW1vcnkgYWRkZWQgYnkgdGhlIEh5cGVyLVYgYmFsbG9vbiBkcml2ZXIpLg0K
PiA+Pg0KPiA+PiBUaGVyZWZvcmUsIGRvbid0IHJlYWQgYW5kIGR1bXAgcGFnZXMgdGhhdCBhcmUg
bWFya2VkIGFzIGJlaW5nIGxvZ2ljYWxseQ0KPiA+PiBvZmZsaW5lLg0KPiA+Pg0KPiA+PiBTaWdu
ZWQtb2ZmLWJ5OiBEYXZpZCBIaWxkZW5icmFuZCA8ZGF2aWRAcmVkaGF0LmNvbT4NCj4gPg0KPiA+
IFRoYW5rcyBmb3IgdGhlIHYyIHVwZGF0ZS4NCj4gPiBJJ20gZ29pbmcgdG8gbWVyZ2UgdGhpcyBw
YXRjaCBhZnRlciB0aGUga2VybmVsIHBhdGNoZXMgYXJlIG1lcmdlZA0KPiA+IGFuZCBpdCB0ZXN0
cyBmaW5lIHdpdGggdGhlIGtlcm5lbC4NCj4gPg0KPiA+IEthenUNCj4gDQo+IEhpIEthenUsDQo+
IA0KPiB0aGUgcGF0Y2hlcyBhcmUgbm93IHVwc3RyZWFtLiBUaGFua3MhDQoNClRlc3RlZCBPSyBh
dCBteSBlbmQsIHRvby4gQXBwbGllZCB0byB0aGUgZGV2ZWwgYnJhbmNoLg0KDQogICAgT2ZmbGlu
ZSBwYWdlcyAgICAgICAgICAgOiAweDAwMDAwMDAwMDAwMDI0MDANCg0KVGhhbmsgeW91IQ0KS2F6
dQ0KDQo+IA0KPiAtLQ0KPiANCj4gVGhhbmtzLA0KPiANCj4gRGF2aWQgLyBkaGlsZGVuYg0KDQo=


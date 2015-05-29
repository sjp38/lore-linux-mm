Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id DBA016B00A0
	for <linux-mm@kvack.org>; Fri, 29 May 2015 17:31:23 -0400 (EDT)
Received: by oifu123 with SMTP id u123so66177759oif.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 14:31:23 -0700 (PDT)
Received: from g9t5008.houston.hp.com (g9t5008.houston.hp.com. [15.240.92.66])
        by mx.google.com with ESMTPS id ow20si4287287oeb.23.2015.05.29.14.31.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 14:31:22 -0700 (PDT)
From: "Elliott, Robert (Server Storage)" <Elliott@hp.com>
Subject: RE: [PATCH v10 12/12] drivers/block/pmem: Map NVDIMM with
 ioremap_wt()
Date: Fri, 29 May 2015 21:29:53 +0000
Message-ID: <94D0CD8314A33A4D9D801C0FE68B40295A92F392@G9W0745.americas.hpqcorp.net>
References: <1432739944-22633-1-git-send-email-toshi.kani@hp.com>
 <1432739944-22633-13-git-send-email-toshi.kani@hp.com>
 <20150529091129.GC31435@pd.tnic>
 <CAPcyv4jHbrUP7bDpw2Cja5x0eMQZBLmmzFXbotQWSEkAiL1s7Q@mail.gmail.com>
 <1432911782.23540.55.camel@misato.fc.hp.com>
 <CAPcyv4g+zYFkEYpa0HCh0Q+2C3wWNr6v3ZU143h52OKf=U=Qvw@mail.gmail.com>
 <CALCETrXXfujebOemesBtgKCkmRTOQFGjdcxjFDF+_P_tv+C0bw@mail.gmail.com>
In-Reply-To: <CALCETrXXfujebOemesBtgKCkmRTOQFGjdcxjFDF+_P_tv+C0bw@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Dan Williams <dan.j.williams@intel.com>
Cc: "Kani, Toshimitsu" <toshi.kani@hp.com>, Borislav Petkov <bp@alien8.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Yigal Korman <yigal@plexistor.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Luis
 Rodriguez <mcgrof@suse.com>, Christoph Hellwig <hch@lst.de>, Matthew Wilcox <willy@linux.intel.com>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBBbmR5IEx1dG9taXJza2kgW21h
aWx0bzpsdXRvQGFtYWNhcGl0YWwubmV0XQ0KPiBTZW50OiBGcmlkYXksIE1heSAyOSwgMjAxNSAx
OjM1IFBNDQouLi4NCj4gV2hvYSwgdGhlcmUhICBXaHkgd291bGQgd2UgdXNlIG5vbi10ZW1wb3Jh
bCBzdG9yZXMgdG8gV0IgbWVtb3J5IHRvDQo+IGFjY2VzcyBwZXJzaXN0ZW50IG1lbW9yeT8gIEkg
Y2FuIHNlZSB0d28gcmVhc29ucyBub3QgdG86DQoNCkRhdGEgd3JpdHRlbiB0byBhIGJsb2NrIHN0
b3JhZ2UgZGV2aWNlIChoZXJlLCB0aGUgTlZESU1NKSBpcyB1bmxpa2VseQ0KdG8gYmUgcmVhZCBv
ciB3cml0dGVuIGFnYWluIGFueSB0aW1lIHNvb24uICBJdCdzIG5vdCBsaWtlIHRoZSBjb2RlDQph
bmQgZGF0YSB0aGF0IGEgcHJvZ3JhbSBoYXMgaW4gbWVtb3J5LCB3aGVyZSB0aGVyZSBtaWdodCBi
ZSBhIGxvb3ANCmFjY2Vzc2luZyB0aGUgbG9jYXRpb24gZXZlcnkgQ1BVIGNsb2NrOyBpdCdzIHN0
b3JhZ2UgSS9PIHRvDQpoaXN0b3JpY2FsbHkgdmVyeSBzbG93IChyZWxhdGl2ZSB0byB0aGUgQ1BV
IGNsb2NrIHNwZWVkKSBkZXZpY2VzLiAgDQpUaGUgc291cmNlIGJ1ZmZlciBmb3IgdGhhdCBkYXRh
IG1pZ2h0IGJlIGZyZXF1ZW50bHkgYWNjZXNzZWQsIA0KYnV0IG5vdCB0aGUgTlZESU1NIHN0b3Jh
Z2UgaXRzZWxmLiAgDQoNCk5vbi10ZW1wb3JhbCBzdG9yZXMgYXZvaWQgd2FzdGluZyBjYWNoZSBz
cGFjZSBvbiB0aGVzZSAib25lLXRpbWUiIA0KYWNjZXNzZXMuICBUaGUgc2FtZSBhcHBsaWVzIGZv
ciByZWFkcyBhbmQgbm9uLXRlbXBvcmFsIGxvYWRzLg0KS2VlcCB0aGUgQ1BVIGRhdGEgY2FjaGUg
bGluZXMgZnJlZSBmb3IgdGhlIGFwcGxpY2F0aW9uLg0KDQpEQVggYW5kIG1tYXAoKSBkbyBjaGFu
Z2UgdGhhdDsgdGhlIGFwcGxpY2F0aW9uIGlzIG5vdyBmcmVlIHRvDQpzdG9yZSBmcmVxdWVudGx5
IGFjY2Vzc2VkIGRhdGEgc3RydWN0dXJlcyBkaXJlY3RseSBpbiBwZXJzaXN0ZW50IA0KbWVtb3J5
LiAgQnV0LCB0aGF0J3Mgbm90IGF2YWlsYWJsZSBpZiBidHQgaXMgdXNlZCwgYW5kIA0KYXBwbGlj
YXRpb24gbG9hZHMgYW5kIHN0b3JlcyB3b24ndCBnbyB0aHJvdWdoIHRoZSBtZW1jcHkoKQ0KY2Fs
bHMgaW5zaWRlIHBtZW0gYW55d2F5LiAgVGhlIG5vbi10ZW1wb3JhbCBpbnN0cnVjdGlvbnMgYXJl
DQpjYWNoZSBjb2hlcmVudCwgc28gZGF0YSBpbnRlZ3JpdHkgd29uJ3QgZ2V0IGNvbmZ1c2VkIGJ5
IHRoZW0NCmlmIEkvTyBnb2luZyB0aHJvdWdoIHBtZW0ncyBibG9jayBzdG9yYWdlIEFQSXMgaGFw
cGVucw0KdG8gb3ZlcmxhcCB3aXRoIHRoZSBhcHBsaWNhdGlvbidzIG1tYXAoKSByZWdpb25zLg0K
DQotLS0NClJvYmVydCBFbGxpb3R0LCBIUCBTZXJ2ZXIgU3RvcmFnZQ0KDQoNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

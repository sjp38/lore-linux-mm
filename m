Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 509576B004D
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 13:28:44 -0500 (EST)
Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: base64
Subject: RE: [Lsf-pc] [dm-devel]  [LSF/MM TOPIC] a few storage topics
Date: Wed, 25 Jan 2012 13:28:42 -0500
Message-ID: <D3F292ADF945FB49B35E96C94C2061B915A63A30@nsmail.netscout.com>
In-Reply-To: <1327512727.2776.52.camel@dabdike.int.hansenpartnership.com>
References: <20120124151504.GQ4387@shiny> <20120124165631.GA8941@infradead.org> <186EA560-1720-4975-AC2F-8C72C4A777A9@dilger.ca> <x49fwf5kmbl.fsf@segfault.boston.devel.redhat.com> <20120124184054.GA23227@infradead.org> <20120124190732.GH4387@shiny> <x49vco0kj5l.fsf@segfault.boston.devel.redhat.com> <20120124200932.GB20650@quack.suse.cz> <x49pqe8kgej.fsf@segfault.boston.devel.redhat.com> <20120124203936.GC20650@quack.suse.cz> <20120125032932.GA7150@localhost> <F6F2DEB8-F096-4A3B-89E3-3A132033BC76@dilger.ca> <1327502034.2720.23.camel@menhir> <D3F292ADF945FB49B35E96C94C2061B915A638A6@nsmail.netscout.com> <1327509623.2720.52.camel@menhir> <1327512727.2776.52.camel@dabdike.int.hansenpartnership.com>
From: "Loke, Chetan" <Chetan.Loke@netscout.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>, Steven Whitehouse <swhiteho@redhat.com>
Cc: Andreas Dilger <adilger@dilger.ca>, Wu Fengguang <fengguang.wu@gmail.com>, Jan Kara <jack@suse.cz>, Jeff Moyer <jmoyer@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-scsi@vger.kernel.org, Mike Snitzer <snitzer@redhat.com>, neilb@suse.de, Christoph Hellwig <hch@infradead.org>, dm-devel@redhat.com, Boaz Harrosh <bharrosh@panasas.com>, linux-fsdevel@vger.kernel.org, lsf-pc@lists.linux-foundation.org, Chris Mason <chris.mason@oracle.com>, "Darrick J.Wong" <djwong@us.ibm.com>, linux-mm@kvack.org

PiBTbyB0aGVyZSBhcmUgdHdvIHNlcGFyYXRlIHByb2JsZW1zIG1lbnRpb25lZCBoZXJlLiAgVGhl
IGZpcnN0IGlzIHRvDQo+IGVuc3VyZSB0aGF0IHJlYWRhaGVhZCAoUkEpIHBhZ2VzIGFyZSB0cmVh
dGVkIGFzIG1vcmUgZGlzcG9zYWJsZSB0aGFuDQo+IGFjY2Vzc2VkIHBhZ2VzIHVuZGVyIG1lbW9y
eSBwcmVzc3VyZSBhbmQgdGhlbiB0byBkZXJpdmUgYSBzdGF0aXN0aWMgZm9yDQo+IGZ1dGlsZSBS
QSAodGhvc2UgcGFnZXMgdGhhdCB3ZXJlIHJlYWQgaW4gYnV0IG5ldmVyIGFjY2Vzc2VkKS4NCj4g
DQo+IFRoZSBmaXJzdCBzb3VuZHMgcmVhbGx5IGxpa2UgaXRzIGFuIExSVSB0aGluZyByYXRoZXIg
dGhhbiBhZGRpbmcgeWV0DQo+IGFub3RoZXIgcGFnZSBmbGFnLiAgV2UgbmVlZCBhIHBvc2l0aW9u
IGluIHRoZSBMUlUgbGlzdCBmb3IgbmV2ZXINCj4gYWNjZXNzZWQgLi4uIHRoYXQgd2F5IHRoZXkn
cmUgZmlyc3QgdG8gYmUgZXZpY3RlZCBhcyBtZW1vcnkgcHJlc3N1cmUNCj4gcmlzZXMuDQo+IA0K
PiBUaGUgc2Vjb25kIGlzIHlvdSBjYW4gZGVyaXZlIHRoaXMgZnV0aWxlIHJlYWRhaGVhZCBzdGF0
aXN0aWMgZnJvbSB0aGUNCj4gTFJVIHBvc2l0aW9uIG9mIHVuYWNjZXNzZWQgcGFnZXMgLi4uIHlv
dSBjb3VsZCBrZWVwIHRoaXMgZ2xvYmFsbHkuDQo+IA0KPiBOb3cgdGhlIHByb2JsZW06IGlmIHlv
dSB0cmFzaCBhbGwgdW5hY2Nlc3NlZCBSQSBwYWdlcyBmaXJzdCwgeW91IGVuZCB1cA0KPiB3aXRo
IHRoZSBzaXR1YXRpb24gb2Ygc2F5IHBsYXlpbmcgYSBtb3ZpZSB1bmRlciBtb2RlcmF0ZSBtZW1v
cnkNCj4gcHJlc3N1cmUgdGhhdCB3ZSBkbyBSQSwgdGhlbiB0cmFzaCB0aGUgUkEgcGFnZSB0aGVu
IGhhdmUgdG8gcmUtcmVhZCB0byBkaXNwbGF5DQo+IHRvIHRoZSB1c2VyIHJlc3VsdGluZyBpbiBh
biB1bmRlc2lyYWJsZSB1cHRpY2sgaW4gcmVhZCBJL08uDQo+IA0KPiBCYXNlZCBvbiB0aGUgYWJv
dmUsIGl0IHNvdW5kcyBsaWtlIGEgYmV0dGVyIGhldXJpc3RpYyB3b3VsZCBiZSB0byBldmljdA0K
PiBhY2Nlc3NlZCBjbGVhbiBwYWdlcyBhdCB0aGUgdG9wIG9mIHRoZSBMUlUgbGlzdCBiZWZvcmUg
dW5hY2Nlc3NlZCBjbGVhbg0KPiBwYWdlcyBiZWNhdXNlIHRoZSBleHBlY3RhdGlvbiBpcyB0aGF0
IHRoZSB1bmFjY2Vzc2VkIGNsZWFuIHBhZ2VzIHdpbGwNCj4gYmUgYWNjZXNzZWQgKHRoYXQncyBh
ZnRlciBhbGwsIHdoeSB3ZSBkaWQgdGhlIHJlYWRhaGVhZCkuICBBcyBSQSBwYWdlcyBhZ2UNCg0K
V2VsbCwgdGhlIG1vdmllIGV4YW1wbGUgaXMgb25lIGNhc2Ugd2hlcmUgZXZpY3RpbmcgdW5hY2Nl
c3NlZCBwYWdlIG1heSBub3QgYmUgdGhlIHJpZ2h0IHRoaW5nIHRvIGRvLiBCdXQgd2hhdCBhYm91
dCBhIHdvcmtsb2FkIHRoYXQgcGVyZm9ybSBhIHJhbmRvbSBvbmUtc2hvdCBzZWFyY2g/DQpUaGUg
c2VhcmNoIHdhcyBkb25lIGFuZCB0aGUgUkEnZCBibG9ja3MgYXJlIG9mIG5vIHVzZSBhbnltb3Jl
LiBTbyBpdCBzZWVtcyBvbmUgc29sdXRpb24gd291bGQgaHVydCBhbm90aGVyLg0KDQpXZSBjYW4g
dHJ5IHRvIGJyaW5nLWluIHByb2Nlc3MgcnVuLXRpbWUgaGV1cmlzdGljcyB3aGlsZSBldmljdGlu
ZyBwYWdlcy4gU28gaW4gdGhlIG9uZS1zaG90IHNlYXJjaCBjYXNlLCB0aGUgYXBwbGljYXRpb24g
ZGlkIGl0J3MgdGhpbmcgYW5kIHdlbnQgdG8gc2xlZXAuDQpXaGlsZSB0aGUgbW92aWUtYXBwIGhh
cyBhIHByZXR0eSBnb29kIHJ1bi10aW1lIGFuZCBpcyBzdGlsbCBydW5uaW5nLiBTbyBiZSBhIGxp
dHRsZSBnZW50bGUoPykgb24gc3VjaCBhcHBzPyBTZWxlY3RpdmUgZXZpY3Rpb24/DQoNCkluIGFk
ZGl0aW9uIHdoYXQgaWYgd2UgZG8gc29tZXRoaW5nIGxpa2UgdGhpczoNCg0KUkEgYmxvY2tbWF0s
IFJBIGJsb2NrW1grMV0sIC4uLiAsIFJBIGJsb2NrW1grbV0NCg0KQXNzdW1lIGEgYmxvY2sgcmVh
ZHMgJ04nIHBhZ2VzLg0KDQpFdmljdCB1bmFjY2Vzc2VkIFJBIHBhZ2UgJ2EnIGZyb20gYmxvY2tb
WCsyXSBhbmQgbm90IFtYKzFdLg0KDQpXZSBtaWdodCBuZWVkIHRyYWNraW5nIGF0IHRoZSBSQS1i
bG9jayBsZXZlbC4gVGhpcyB3YXkgaWYgYSBtb3ZpZSB0b3VjaGVkIFJBLXBhZ2UgJ2EnIGZyb20g
YmxvY2tbWF0sIGl0IHdvdWxkIGF0IGxlYXN0IGhhdmUgW1grMV0gaW4gY2FjaGUuIEFuZCB3aGls
ZSBbWCsxXSBpcyBiZWluZyByZWFkLCB0aGUgbmV3IHNsb3ctZG93biB2ZXJzaW9uIG9mIFJBIHdp
bGwgbm90IFJBIHRoYXQgbWFueSBibG9ja3MuDQoNCkFsc28sIGFwcGxpY2F0aW9uJ3Mgc2hvdWxk
IHVzZSB4eHhfZmFkdmlzZSBjYWxscyB0byBnaXZlIHVzIGhpbnRzLi4uDQoNCg0KPiBKYW1lcw0K
DQpDaGV0YW4gTG9rZQ0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

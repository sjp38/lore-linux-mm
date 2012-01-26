Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 367316B004F
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 11:17:08 -0500 (EST)
Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: base64
Subject: RE: [Lsf-pc] [dm-devel]  [LSF/MM TOPIC] a few storage topics
Date: Thu, 26 Jan 2012 11:17:05 -0500
Message-ID: <D3F292ADF945FB49B35E96C94C2061B915A640A5@nsmail.netscout.com>
In-Reply-To: <1327516668.7168.7.camel@dabdike.int.hansenpartnership.com>
References: <20120124151504.GQ4387@shiny> <20120124165631.GA8941@infradead.org> <186EA560-1720-4975-AC2F-8C72C4A777A9@dilger.ca> <x49fwf5kmbl.fsf@segfault.boston.devel.redhat.com> <20120124184054.GA23227@infradead.org> <20120124190732.GH4387@shiny> <x49vco0kj5l.fsf@segfault.boston.devel.redhat.com> <20120124200932.GB20650@quack.suse.cz> <x49pqe8kgej.fsf@segfault.boston.devel.redhat.com> <20120124203936.GC20650@quack.suse.cz> <20120125032932.GA7150@localhost> <F6F2DEB8-F096-4A3B-89E3-3A132033BC76@dilger.ca> <1327502034.2720.23.camel@menhir> <D3F292ADF945FB49B35E96C94C2061B915A638A6@nsmail.netscout.com> <1327509623.2720.52.camel@menhir> <1327512727.2776.52.camel@dabdike.int.hansenpartnership.com> <D3F292ADF945FB49B35E96C94C2061B915A63A30@nsmail.netscout.com> <1327516668.7168.7.camel@dabdike.int.hansenpartnership.com>
From: "Loke, Chetan" <Chetan.Loke@netscout.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Steven Whitehouse <swhiteho@redhat.com>, Andreas Dilger <adilger@dilger.ca>, Andrea Arcangeli <aarcange@redhat.com>, Jan Kara <jack@suse.cz>, Mike Snitzer <snitzer@redhat.com>, linux-scsi@vger.kernel.org, neilb@suse.de, dm-devel@redhat.com, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Wu Fengguang <fengguang.wu@gmail.com>, Boaz Harrosh <bharrosh@panasas.com>, linux-fsdevel@vger.kernel.org, lsf-pc@lists.linux-foundation.org, Chris Mason <chris.mason@oracle.com>, "Darrick J.Wong" <djwong@us.ibm.com>

PiA+IFdlbGwsIHRoZSBtb3ZpZSBleGFtcGxlIGlzIG9uZSBjYXNlIHdoZXJlIGV2aWN0aW5nIHVu
YWNjZXNzZWQgcGFnZSBtYXkgbm90IGJlIHRoZSByaWdodCB0aGluZyB0byBkby4gQnV0IHdoYXQg
YWJvdXQgYSB3b3JrbG9hZCB0aGF0IHBlcmZvcm0gYSByYW5kb20gb25lLXNob3Qgc2VhcmNoPw0K
PiA+IFRoZSBzZWFyY2ggd2FzIGRvbmUgYW5kIHRoZSBSQSdkIGJsb2NrcyBhcmUgb2Ygbm8gdXNl
IGFueW1vcmUuIFNvIGl0IHNlZW1zIG9uZSBzb2x1dGlvbiB3b3VsZCBodXJ0IGFub3RoZXIuDQo+
IA0KPiBXZWxsIG5vdCByZWFsbHk6IFJBIGlzIGFsd2F5cyB3cm9uZyBmb3IgcmFuZG9tIHJlYWRz
LiAgVGhlIHdob2xlIHB1cnBvc2Ugb2YgUkEgaXMgYXNzdW1wdGlvbiBvZiBzZXF1ZW50aWFsIGFj
Y2VzcyBwYXR0ZXJucy4NCj4gDQoNCkphbWVzIC0gSSBtdXN0IGFncmVlIHRoYXQgJ3JhbmRvbScg
d2FzIG5vdCB0aGUgcHJvcGVyIGNob2ljZSBvZiB3b3JkIGhlcmUuIFdoYXQgSSBtZWFudCB3YXMg
dGhpcyAtIA0KDQpzZWFyY2gtYXBwIHJlYWRzIGVub3VnaCBkYXRhIHRvIHRyaWNrIHRoZSBsYXp5
L2RlZmVycmVkLVJBIGxvZ2ljLiBSQSB0aGlua3MsIG9oIHdlbGwsIHRoaXMgaXMgbm93IGEgc2Vx
dWVudGlhbCBwYXR0ZXJuIGFuZCB3aWxsIFJBLg0KQnV0IGFsbCB0aGlzIHNlYXJjaC1hcHAgZGlk
IHdhcyB0aGF0IGl0IGtlcHQgcmVhZGluZyB0aWxsIGl0IGZvdW5kIHdoYXQgaXQgd2FzIGxvb2tp
bmcgZm9yLiBPbmNlIGl0IHdhcyBkb25lLCBpdCB3ZW50IGJhY2sgdG8gc2xlZXAgd2FpdGluZyBm
b3IgdGhlIG5leHQgcXVlcnkuDQpOb3cgYWxsIHRoYXQgUkEgZGF0YSBjb3VsZCBiZSBvZiB0b3Rh
bCB3YXN0ZSBpZiB0aGUgcmVhZC1oaXQgb24gdGhlIFJBIGRhdGEtc2V0IHdhcyAnemVybyBwZXJj
ZW50Jy4NCg0KU29tZSB3b3VsZCBhcmd1ZSB0aGF0IGhvdyB3b3VsZCB3ZSh0aGUga2VybmVsKSBr
bm93IHRoYXQgdGhlIG5leHQgcXVlcnkgbWF5IG5vdCBiZSBjbG9zZSB0aGUgZWFybGllciBkYXRh
LXNldD8gV2VsbCwgd2UgZG9uJ3QgYW5kIHdlIG1heSBub3Qgd2FudCB0by4gVGhhdCBpcyB3aHkg
dGhlIGFwcGxpY2F0aW9uIGJldHRlciBrbm93IGhvdyB0byB1c2UgWFhYX2FkdmlzZSBjYWxscy4g
SWYgdGhleSBhcmUgbm90IHVzaW5nIGl0IHRoZW4gd2VsbCBpdCdzIHRoZWlyIHByb2JsZW0uIFRo
ZSBhcHAga25vd3MgYWJvdXQgdGhlIHN0YXRpc3RpY3MvZXRjIGFib3V0IHRoZSBxdWVyaWVzLiBX
aGF0IHdhcyB1c2VkIGFuZCB3aGF0IHdhc24ndC4NCg0KDQo+IEphbWVzDQoNCkNoZXRhbiBMb2tl
DQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

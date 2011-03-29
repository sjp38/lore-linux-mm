Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 83D238D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 09:51:15 -0400 (EDT)
Received: by yib18 with SMTP id 18so95152yib.14
        for <linux-mm@kvack.org>; Tue, 29 Mar 2011 06:51:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110329134547.GC3361@tiehlicka.suse.cz>
References: <20110329132800.GA3361@tiehlicka.suse.cz> <AANLkTikYepYY01P+MELCpT+nFiPor3+-Oo=kyr2FE03C@mail.gmail.com>
 <20110329134547.GC3361@tiehlicka.suse.cz>
From: Zhu Yanhai <zhu.yanhai@gmail.com>
Date: Tue, 29 Mar 2011 21:50:51 +0800
Message-ID: <AANLkTikkQnpZn0ouGgLH7-1T5zYQPU9kZ-yh3xj6vfPs@mail.gmail.com>
Subject: Re: [trivial PATCH] Remove pointless next_mz nullification in mem_cgroup_soft_limit_reclaim
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

R290IGl0LiBTb3JyeSwgbXkgZmF1bHQgOikKCi16eWgKCjIwMTEvMy8yOSBNaWNoYWwgSG9ja28g
PG1ob2Nrb0BzdXNlLmN6PjoKPiBPbiBUdWUgMjktMDMtMTEgMjE6NDA6MTMsIFpodSBZYW5oYWkg
d3JvdGU6Cj4+IE1pY2hhbCwKPj4gSUlVQyBpdCdzIHRvIHByZXZlbnQgdGhlIGluZmluaXRlIGxv
b3AsIGFzIGluIHRoZSBlbmQgb2YgdGhlIGRvLXdoaWxlCj4+IHRoZXJlJ3MKPj4gaWYgKCFucl9y
ZWNsYWltZWQgJiYKPj4gwqAgwqAgKG5leHRfbXogPT0gTlVMTCB8fAo+PiDCoCDCoCBsb29wID4g
TUVNX0NHUk9VUF9NQVhfU09GVF9MSU1JVF9SRUNMQUlNX0xPT1BTKSkKPj4gwqAgwqAgwqAgwqAg
wqAgwqAgwqAgYnJlYWs7Cj4KPj4gc28gdGhlIGxvb3Agd2lsbCBicmVhayBlYXJsaWVyIGlmIGFs
bCBncm91cHMgYXJlIGl0ZXJhdGVkIG9uY2UgYW5kIG5vCj4+IHBhZ2VzIGFyZSBmcmVlZC4KPgo+
IFRoZSBjb2RlIChpbiBtbW90bSAyMDExLTAzLTEwLTE2LTQyKSByZWFkczoKPiDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoGRvIHsKPiDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoFtza2lwcGVkIGNvbW1lbnRzXQo+IMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgbmV4dF9teiA9Cj4gwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqBfX21lbV9jZ3JvdXBfbGFyZ2VzdF9z
b2Z0X2xpbWl0X25vZGUobWN0eik7Cj4gwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqBpZiAobmV4dF9teiA9PSBteikgewo+IMKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgY3NzX3B1dCgmbmV4dF9tei0+
bWVtLT5jc3MpOwo+IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgbmV4dF9teiA9IE5VTEw7Cj4gwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqB9IGVsc2UgLyogbmV4dF9teiA9PSBOVUxMIG9yIG90aGVy
IG1lbWNnICovCj4gwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqBicmVhazsKPiDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oH0gd2hpbGUgKDEpOwo+Cj4gU28gd2UgZG8gbm90IGJyZWFrIG91dCBvZiB0aGUgbG9vcCBhbmQg
c3RhcnQgYSBuZXcgaXRlcmF0aW9uIGlmIG5leHRfbXogPT0gbXoKPiBhbmQgYXNzaWduIG5leHRf
bXogYWdhaW4uCj4gQW0gSSBtaXNzaW5nIHNvbWV0aGluZz8KPiAtLQo+IE1pY2hhbCBIb2Nrbwo+
IFNVU0UgTGFicwo+IFNVU0UgTElOVVggcy5yLm8uCj4gTGlob3ZhcnNrYSAxMDYwLzEyCj4gMTkw
IDAwIFByYWhhIDkKPiBDemVjaCBSZXB1YmxpYwo+Cg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

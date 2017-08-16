From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [patch net-next 0/3] net/sched: Improve getting objects by indexes
Date: Wed, 16 Aug 2017 10:19:53 +0100
Message-ID: <150287519355.15499.3124883464555211520@mail.alporthouse.com>
References: <1502849538-14284-1-git-send-email-chrism@mellanox.com>
 <144b87a3-bbe4-a194-ed83-e54840d7c7c2@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org>
In-Reply-To: <144b87a3-bbe4-a194-ed83-e54840d7c7c2@amd.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/ath10k/>
List-Post: <mailto:ath10k@lists.infradead.org>
List-Help: <mailto:ath10k-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=subscribe>
Sender: "ath10k" <ath10k-bounces@lists.infradead.org>
Errors-To: ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org
To: =?utf-8?q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, Chris Mi <chrism@mellanox.com>, netdev@vger.kernel.org
Cc: lucho@ionkov.net, sergey.senozhatsky.work@gmail.com, snitzer@redhat.com, wsa@the-dreams.de, markb@mellanox.com, tom.leiming@gmail.com, stefanr@s5r6.in-berlin.de, zhi.a.wang@intel.com, nsekhar@ti.com, dri-devel@lists.freedesktop.org, bfields@fieldses.org, linux-sctp@vger.kernel.org, paulus@samba.org, jinpu.wang@profitbricks.com, pshelar@ovn.org, sumit.semwal@linaro.org, AlexBin.Xie@amd.com, david1.zhou@amd.com, linux-samsung-soc@vger.kernel.org, maximlevitsky@gmail.com, sudarsana.kalluru@qlogic.com, marek.vasut@gmail.com, linux-atm-general@lists.sourceforge.net, dtwlin@gmail.com, michel.daenzer@amd.com, dledford@redhat.com, tpmdd-devel@lists.sourceforge.net, stern@rowland.harvard.edu, longman@redhat.com, niranjana.vishwanathapura@intel.com, philipp.reisner@linbit.com, shli@kernel.org, linux@roeck-us.net, ohad@wizery.com, pmladek@suse.com, dick.kennedy@broadcom.comlinux-
List-Id: linux-mm.kvack.org

UXVvdGluZyBDaHJpc3RpYW4gS8O2bmlnICgyMDE3LTA4LTE2IDA4OjQ5OjA3KQo+IEFtIDE2LjA4
LjIwMTcgdW0gMDQ6MTIgc2NocmllYiBDaHJpcyBNaToKPiA+IFVzaW5nIGN1cnJlbnQgVEMgY29k
ZSwgaXQgaXMgdmVyeSBzbG93IHRvIGluc2VydCBhIGxvdCBvZiBydWxlcy4KPiA+Cj4gPiBJbiBv
cmRlciB0byBpbXByb3ZlIHRoZSBydWxlcyB1cGRhdGUgcmF0ZSBpbiBUQywKPiA+IHdlIGludHJv
ZHVjZWQgdGhlIGZvbGxvd2luZyB0d28gY2hhbmdlczoKPiA+ICAgICAgICAgIDEpIGNoYW5nZWQg
Y2xzX2Zsb3dlciB0byB1c2UgSURSIHRvIG1hbmFnZSB0aGUgZmlsdGVycy4KPiA+ICAgICAgICAg
IDIpIGNoYW5nZWQgYWxsIGFjdF94eHggbW9kdWxlcyB0byB1c2UgSURSIGluc3RlYWQgb2YKPiA+
ICAgICAgICAgICAgIGEgc21hbGwgaGFzaCB0YWJsZQo+ID4KPiA+IEJ1dCBJRFIgaGFzIGEgbGlt
aXRhdGlvbiB0aGF0IGl0IHVzZXMgaW50LiBUQyBoYW5kbGUgdXNlcyB1MzIuCj4gPiBUbyBtYWtl
IHN1cmUgdGhlcmUgaXMgbm8gcmVncmVzc2lvbiwgd2UgYWxzbyBjaGFuZ2VkIElEUiB0byB1c2UK
PiA+IHVuc2lnbmVkIGxvbmcuIEFsbCBjbGllbnRzIG9mIElEUiBhcmUgY2hhbmdlZCB0byB1c2Ug
bmV3IElEUiBBUEkuCj4gCj4gV09XLCB3YWl0IGEgc2Vjb25kLiBUaGUgaWRyIGNoYW5nZSBpcyB0
b3VjaGluZyBhIGxvdCBvZiBkcml2ZXJzIGFuZCB0byAKPiBiZSBob25lc3QgZG9lc24ndCBsb29r
cyBjb3JyZWN0IGF0IGFsbC4KPiAKPiBKdXN0IGxvb2sgYXQgdGhlIGZpcnN0IGNodW5rIG9mIHlv
dXIgbW9kaWZpY2F0aW9uOgo+ID4gQEAgLTk5OCw4ICs5OTksOSBAQCBpbnQgYnNnX3JlZ2lzdGVy
X3F1ZXVlKHN0cnVjdCByZXF1ZXN0X3F1ZXVlICpxLCBzdHJ1Y3QgZGV2aWNlICpwYXJlbnQsCj4g
PiAgIAo+ID4gICAgICAgbXV0ZXhfbG9jaygmYnNnX211dGV4KTsKPiA+ICAgCj4gPiAtICAgICBy
ZXQgPSBpZHJfYWxsb2MoJmJzZ19taW5vcl9pZHIsIGJjZCwgMCwgQlNHX01BWF9ERVZTLCBHRlBf
S0VSTkVMKTsKPiA+IC0gICAgIGlmIChyZXQgPCAwKSB7Cj4gPiArICAgICByZXQgPSBpZHJfYWxs
b2MoJmJzZ19taW5vcl9pZHIsIGJjZCwgJmlkcl9pbmRleCwgMCwgQlNHX01BWF9ERVZTLAo+ID4g
KyAgICAgICAgICAgICAgICAgICAgIEdGUF9LRVJORUwpOwo+ID4gKyAgICAgaWYgKHJldCkgewo+
ID4gICAgICAgICAgICAgICBpZiAocmV0ID09IC1FTk9TUEMpIHsKPiA+ICAgICAgICAgICAgICAg
ICAgICAgICBwcmludGsoS0VSTl9FUlIgImJzZzogdG9vIG1hbnkgYnNnIGRldmljZXNcbiIpOwo+
ID4gICAgICAgICAgICAgICAgICAgICAgIHJldCA9IC1FSU5WQUw7Cj4gVGhlIGNvbmRpdGlvbiAi
aWYgKHJldCkiIHdpbGwgbm93IGFsd2F5cyBiZSB0cnVlIGFmdGVyIHRoZSBmaXJzdCAKPiBhbGxv
Y2F0aW9uIGFuZCBzbyB3ZSBhbHdheXMgcnVuIGludG8gdGhlIGVycm9yIGhhbmRsaW5nIGFmdGVy
IHRoYXQuCgpyZXQgaXMgbm93IHB1cmVseSB0aGUgZXJyb3IgY29kZSwgc28gaXQgZG9lc24ndCBs
b29rIHRoYXQgc3VzcGljaW91cy4KCj4gSSd2ZSBuZXZlciByZWFkIHRoZSBic2cgY29kZSBiZWZv
cmUsIGJ1dCB0aGF0J3MgY2VydGFpbmx5IG5vdCBjb3JyZWN0LiAKPiBBbmQgdGhhdCBpbmNvcnJl
Y3QgcGF0dGVybiByZXBlYXRzIG92ZXIgYW5kIG92ZXIgYWdhaW4gaW4gdGhpcyBjb2RlLgo+IAo+
IEFwYXJ0IGZyb20gdGhhdCB3aHkgdGhlIGhlY2sgZG8geW91IHdhbnQgdG8gYWxsb2NhdGUgbW9y
ZSB0aGFuIDE8PDMxIAo+IGhhbmRsZXM/CgpBbmQgbW9yZSB0byB0aGUgcG9pbnQsIGFyYml0cmFy
aWx5IGNoYW5naW5nIHRoZSBtYXhpbXVtIHRvIFVMT05HX01BWAp3aGVyZSB0aGUgQUJJIG9ubHkg
c3VwcG9ydHMgVTMyX01BWCBpcyBkYW5nZXJvdXMuIFVubGVzcyB5b3UgZG8gdGhlCmFuYWx5c2lz
IG90aGVyd2lzZSwgeW91IGhhdmUgdG8gcmVwbGFjZSBhbGwgdGhlIGVuZD0wIHdpdGggZW5kPUlO
VF9NQVgKdG8gbWFpbnRhaW4gZXhpc3RpbmcgYmVoYXZpb3VyLgotQ2hyaXMKCl9fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCmF0aDEwayBtYWlsaW5nIGxpc3QK
YXRoMTBrQGxpc3RzLmluZnJhZGVhZC5vcmcKaHR0cDovL2xpc3RzLmluZnJhZGVhZC5vcmcvbWFp
bG1hbi9saXN0aW5mby9hdGgxMGsK

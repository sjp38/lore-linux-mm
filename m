From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH V2 1/2] mm: move FAULT_AROUND_ORDER to arch/
Date: Mon, 07 Apr 2014 15:45:34 +1000
Message-ID: <1396849534.3671.35.camel@pasglop>
References: <1396592835-24767-1-git-send-email-maddy@linux.vnet.ibm.com>
 <1396592835-24767-2-git-send-email-maddy@linux.vnet.ibm.com>
 <533EDB63.8090909@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <533EDB63.8090909@intel.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-arch@vger.kernel.org, rusty@rustcorp.com.au, Madhavan Srinivasan <maddy@linux.vnet.ibm.com>, riel@redhat.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, ak@linux.intel.com, paulus@samba.org, mgorman@suse.de, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, mingo@kernel.org, kirill.shutemov@linux.intel.com
List-Id: linux-mm.kvack.org

T24gRnJpLCAyMDE0LTA0LTA0IGF0IDA5OjE4IC0wNzAwLCBEYXZlIEhhbnNlbiB3cm90ZToKPiBP
biAwNC8wMy8yMDE0IDExOjI3IFBNLCBNYWRoYXZhbiBTcmluaXZhc2FuIHdyb3RlOgo+ID4gVGhp
cyBwYXRjaCBjcmVhdGVzIGluZnJhc3RydWN0dXJlIHRvIG1vdmUgdGhlIEZBVUxUX0FST1VORF9P
UkRFUgo+ID4gdG8gYXJjaC8gdXNpbmcgS2NvbmZpZy4gVGhpcyB3aWxsIGVuYWJsZSBhcmNoaXRl
Y3R1cmUgbWFpbnRhaW5lcnMKPiA+IHRvIGRlY2lkZSBvbiBzdWl0YWJsZSBGQVVMVF9BUk9VTkRf
T1JERVIgdmFsdWUgYmFzZWQgb24KPiA+IHBlcmZvcm1hbmNlIGRhdGEgZm9yIHRoYXQgYXJjaGl0
ZWN0dXJlLiBQYXRjaCBhbHNvIGFkZHMKPiA+IEZBVUxUX0FST1VORF9PUkRFUiBLY29uZmlnIGVs
ZW1lbnQgaW4gYXJjaC9YODYuCj4gCj4gUGxlYXNlIGRvbid0IGRvIGl0IHRoaXMgd2F5Lgo+IAo+
IEluIG1tL0tjb25maWcsIHB1dAo+IAo+IAljb25maWcgRkFVTFRfQVJPVU5EX09SREVSCj4gCQlp
bnQKPiAJCWRlZmF1bHQgMTIzNCBpZiBQT1dFUlBDCj4gCQlkZWZhdWx0IDQKPiAKPiBUaGUgd2F5
IHlvdSBoYXZlIGl0IG5vdywgZXZlcnkgc2luZ2xlIGFyY2hpdGVjdHVyZSB0aGF0IG5lZWRzIHRv
IGVuYWJsZQo+IHRoaXMgaGFzIHRvIGdvIHB1dCB0aGF0IGluIHRoZWlyIEtjb25maWcuICBUaGF0
J3MgbWFkbmVzcy4gIFRoaXMgd2F5LAo+IHlvdSBvbmx5IHB1dCBpdCBpbiBvbmUgcGxhY2UsIGFu
ZCBmb2xrcyBvbmx5IGhhdmUgdG8gY2FyZSBpZiB0aGV5IHdhbnQKPiB0byBjaGFuZ2UgdGhlIGRl
ZmF1bHQgdG8gYmUgc29tZXRoaW5nIG90aGVyIHRoYW4gNC4KCkFsc28gZG9lcyBpdCBoYXZlIHRv
IGJlIGEgY29uc3RhbnQgPyBNYWRkeSBoZXJlIHRlc3RlZCBvbiBvdXIgUE9XRVIKc2VydmVycy4g
VGhlICJTd2VldCBzcG90IiB2YWx1ZSBtaWdodCBiZSBWRVJZIGRpZmZlcmVudCBvbiBhbiBlbWJl
ZGRlZApjaGlwIG9yIGV2ZW4gb24gYSBmdXR1cmUgZ2VuZXJhdGlvbiBvZiBzZXJ2ZXIgY2hpcC4K
CkNoZWVycywKQmVuLgoKCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fCkxpbnV4cHBjLWRldiBtYWlsaW5nIGxpc3QKTGludXhwcGMtZGV2QGxpc3RzLm96bGFi
cy5vcmcKaHR0cHM6Ly9saXN0cy5vemxhYnMub3JnL2xpc3RpbmZvL2xpbnV4cHBjLWRldg==

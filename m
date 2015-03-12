From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] mm: kill kmemcheck
Date: Thu, 12 Mar 2015 09:47:54 -0400
Message-ID: <20150312094754.458606bb@gandalf.local.home>
References: <1426074547-21888-1-git-send-email-sasha.levin@oracle.com>
 <1426132192.25936.7.camel@ellerman.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1426132192.25936.7.camel@ellerman.id.au>
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
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Geert Uytterhoeven <geert+renesas@glider.be>, "open list:SUPERH" <linux-sh@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Mackerras <paulus@samba.org>, Pavel Machek <pavel@ucw.cz>, Miklos Szeredi <mszeredi@suse.cz>, Christoph Lameter <cl@linux.com>, Marek Szyprowski <m.szyprowski@samsung.com>, "open list:GENERIC INCLUDE/A..." <linux-arch@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Russell King <linux@arm.linux.org.uk>, Jingoo Han <jg1.han@samsung.com>, James Morris <jmorris@namei.org>, Chris Bainbridge <chris.bainbridge@gmail.com>, Antti Palosaari <crope@iki.fi>, Mel Gorman <mgorman@suse.de>, Ritesh Harjani <ritesh.harjani@gmail.com>, Shaohua Li <shli@kernel.org>, Alexander Duyck <alexander.h.duyck@intel.com>, Wang Nan <wangnan0@huawei>
List-Id: linux-mm.kvack.org

T24gVGh1LCAxMiBNYXIgMjAxNSAxNDo0OTo1MiArMTEwMApNaWNoYWVsIEVsbGVybWFuIDxtcGVA
ZWxsZXJtYW4uaWQuYXU+IHdyb3RlOgo+IAo+ID5Gcm9tIERvY3VtZW50YXRpb24va2FzYW4udHh0
Ogo+IAo+ICAgICB0aGVyZWZvcmUgeW91IHdpbGwgbmVlZCBhIGNlcnRhaW4gdmVyc2lvbiBvZiBH
Q0MgPiA0LjkuMgo+IAo+IEFGQUlLIGdjYyA0LjkuMyBoYXNuJ3QgYmVlbiByZWxlYXNlZCB5ZXQu
IChPciBkb2VzIGl0IG1lYW4gPj0gNC45LjIgPykKCkl0IG1lYW5zIDQuOS4yLiBJIGFsc28gZmVl
bCB0aGF0IHRoaXMgbWFrZXMgaXQgdG9vIHByZW1hdHVyZSB0byByZW1vdmUKa21lbWNoZWNrLCBh
cyBub3QgZXZlcnlvbmUgKGluY2x1ZGluZyBteXNlbGYpIGhhcyB0aGUgbGF0ZXN0IGFuZApncmVh
dGVzdCBnY2Mgb24gdGhlaXIgc3lzdGVtcy4KCj4gCj4gQ2FuIHdlIHBlcmhhcHMgd2FpdCB1bnRp
bCB0aGVyZSBpcyBhIHJlbGVhc2VkIHZlcnNpb24gb2YgR0NDIHRoYXQgc3VwcG9ydHMKPiBLQVNh
bj8gQW5kIG1heWJlIHRoZW4gYSB0b3VjaCBsb25nZXIgc28gZm9sa3MgY2FuIHRlc3QgaXQgd29y
a3Mgb24gdGhlaXIKPiBwbGF0Zm9ybXM/Cj4gCgpOb3RlLCBJIHJlcGxpZWQgdG8gdGhpcyBjdXR0
aW5nIG91dCB0aGUgQ2MncyB0byB0aGUgaW5kaXZpZHVhbHMgc28gdGhhdAppdCBjYW4gaGF2ZSBh
IHdpZGVyIGF1ZGllbmNlISAoZmlndXJlIG91dCB3aGF0IEkgbWVhbiBieSB0aGF0KS4gWW91IGNh
bgpzZWUgbXkgcmVwbHkgb24gTEtNTCAoaGludCwgeW91IHdvbnQgc2VlIHRoZSBvcmlnaW5hbCBl
bWFpbCwgb3IgdGhpcwpjdXJyZW50IHRocmVhZCBmb3IgdGhhdCBtYXR0ZXIpLgoKLS0gU3RldmUK
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KTGludXhwcGMt
ZGV2IG1haWxpbmcgbGlzdApMaW51eHBwYy1kZXZAbGlzdHMub3psYWJzLm9yZwpodHRwczovL2xp
c3RzLm96bGFicy5vcmcvbGlzdGluZm8vbGludXhwcGMtZGV2

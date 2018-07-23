From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [RESEND] Spectre-v2 (IBPB/IBRS) and SSBD fixes for
 4.4.y
Date: Tue, 24 Jul 2018 00:06:19 +0200 (CEST)
Message-ID: <nycvar.YFH.7.76.1807232357440.997@cbobk.fhfr.pm>
References: <153156030832.10043.13438231886571087086.stgit@srivatsa-ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <xen-devel-bounces@lists.xenproject.org>
In-Reply-To: <153156030832.10043.13438231886571087086.stgit@srivatsa-ubuntu>
List-Unsubscribe: <https://lists.xenproject.org/mailman/options/xen-devel>,
 <mailto:xen-devel-request@lists.xenproject.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xenproject.org>
List-Help: <mailto:xen-devel-request@lists.xenproject.org?subject=help>
List-Subscribe: <https://lists.xenproject.org/mailman/listinfo/xen-devel>,
 <mailto:xen-devel-request@lists.xenproject.org?subject=subscribe>
Errors-To: xen-devel-bounces@lists.xenproject.org
Sender: "Xen-devel" <xen-devel-bounces@lists.xenproject.org>
To: "Srivatsa S. Bhat" <srivatsa@csail.mit.edu>
Cc: Dave Hansen <dave@sr71.net>, Wanpeng Li <kernellwp@gmail.com>, Andi Kleen <ak@linux.intel.com>, linux-tip-commits@vger.kernel.org, Piotr Luc <piotr.luc@intel.com>, Mel Gorman <mgorman@suse.de>, arjan.van.de.ven@intel.com, xen-devel@lists.xenproject.org, Alexander Sergeyev <sergeev917@gmail.com>, Brian Gerst <brgerst@gmail.com>, Andy Lutomirski <luto@kernel.org>, =?ISO-8859-15?Q?Micka=EBlSala=FCn?= <mic@digikod.net>, Thomas Gleixner <tglx@linutronix.de>, Joe Konno <joe.konno@linux.intel.com>, Laura Abbott <labbott@fedoraproject.org>, Will Drewry <wad@chromium.org>, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, Jia Zhang <qianyue.zj@alibaba-inc.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Woodhouse <dwmw@amazon.co.uk>, KarimAllah Ahmed <karahmed@amazon.de>, Dave Hansen <dave.hansen@linux.intel.com>lin
List-Id: linux-mm.kvack.org

T24gU2F0LCAxNCBKdWwgMjAxOCwgU3JpdmF0c2EgUy4gQmhhdCB3cm90ZToKCj4gVGhpcyBwYXRj
aCBzZXJpZXMgaXMgYSBiYWNrcG9ydCBvZiB0aGUgU3BlY3RyZS12MiBmaXhlcyAoSUJQQi9JQlJT
KQo+IGFuZCBwYXRjaGVzIGZvciB0aGUgU3BlY3VsYXRpdmUgU3RvcmUgQnlwYXNzIHZ1bG5lcmFi
aWxpdHkgdG8gNC40LnkKPiAodGhleSBhcHBseSBjbGVhbmx5IG9uIHRvcCBvZiA0LjQuMTQwKS4K
CkZXSVcgLS0gbm90IHN1cmUgaG93IG11Y2ggaW5zcGlyYXRpb24geW91IHRvb2sgZnJvbSBvdXIg
U0xFIDQuNC1iYXNlZCAKdHJlZSwgYnV0IG1vc3Qgb2YgdGhlIHN0dWZmIGlzIGFscmVhZHkgdGhl
cmUgZm9yIHF1aXRlIHNvbWUgdGltZSAKKGluY2x1ZGluZyB0aGUgbm9uLXVwc3RyZWFtIElCUlMg
b24ga2VybmVsIGJvdW5kYXJ5IG9uIFNLTCssIHRyYW1wb2xpbmUgCnN0YWNrIGZvciBQVEkgKHdo
aWNoIHRoZSBvcmlnaW5hbCBwb3J0IGRpZG4ndCBoYXZlKSwgZXRjKS4KClRoZSBJQlJTIFNLTCsg
c3R1ZmYgaGFzIG5vdCBiZWVuIHBpY2tlZCB1cCBieSBHcmVnLCBhcyBpdCdzIG5vbi11cHN0cmVh
bSwgCmFuZCB0aGUgdHJhbXBvbGluZSBzdGFjayBJIGJlbGlldmUgd2FzIHBvaW50ZWQgb3V0IHRv
IHN0YWJsZUAsIGJ1dCBub29uZSAKcmVhbGx5IHNhdCBkb3duIGFuZCBkaWQgdGhlIHBvcnQgKG91
ciBjb2RlYmFzZSBpcyBkaWZmZXJlbnQgdGhhbiA0LjQueCAKc3RhYmxlIGJhc2UpLCBidXQgaXQg
ZGVmaW5pdGVseSBzaG91bGQgYmUgZG9uZSBpZiBzb21lb25lIGhhcyB0byBwdXQgMTAwJSAKdHJ1
c3QgaW50byB0aGUgUFRJIHBvcnQgKGVpdGhlciB0aGF0LCBvciBhdCBsZWFzdCB6ZXJvaW5nIG91
dCB0aGUga2VybmVsIAp0aHJlYWQgdGhyZWFkIHN0YWNrIC4uLiB3ZSB1c2VkIHRvIGhhdmUgdGVt
cG9yYXJpbHkgdGhhdCBiZWZvcmUgd2UgCnN3aXRjaGVkIG92ZXIgdG8gcHJvcGVyIGVudHJ5IHRy
YW1wb2xpbmUgaW4gdGhpcyB2ZXJzaW9uIGFzIHdlbGwpLgoKVGhhbmtzLAoKLS0gCkppcmkgS29z
aW5hClNVU0UgTGFicwoKCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fClhlbi1kZXZlbCBtYWlsaW5nIGxpc3QKWGVuLWRldmVsQGxpc3RzLnhlbnByb2plY3Qu
b3JnCmh0dHBzOi8vbGlzdHMueGVucHJvamVjdC5vcmcvbWFpbG1hbi9saXN0aW5mby94ZW4tZGV2
ZWw=

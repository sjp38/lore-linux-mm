From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [kernel-hardening] Re: [PATCH 9/9] mm: SLUB hardened usercopy
 support
Date: Sat, 09 Jul 2016 16:07:29 +1000
Message-ID: <22011.5033946515$1468044530@news.gmane.org>
References: <577f7e55.4668420a.84f17.5cb9SMTPIN_ADDED_MISSING@mx.google.com>
 <alpine.DEB.2.20.1607080844370.3379@east.gentwo.org>
 <CAGXu5jKE=h32tHVLsDeaPN1GfC+BB3YbFvC+5TE5TK1oR-xU3A@mail.gmail.com>
 <alpine.DEB.2.20.1607081119170.6192@east.gentwo.org>
 <CAGXu5j+UdkQA+k39GNLe5CwBPVD5ZbRGTCQLqS8VF=kWx+PtsQ@mail.gmail.com>
 <CAGXu5jKxw3RxWNKLX4XVCwJ6x_zA=_RwiU9jLDm2+VRO79G7+w@mail.gmail.com>
 <8737njpd37.fsf@@concordia.ellerman.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <8737njpd37.fsf@@concordia.ellerman.id.au>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
To: Kees Cook <keescook@chromium.org>, Christoph Lameter <cl@linux.com>
Cc: Jan Kara <jack@suse.cz>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Linux-MM <linux-mm@kvack.org>, sparclinux <sparclinux@vger.kernel.org>, linux-ia64@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "x86@kernel.org" <x86@kernel.org>, Russell King <linux@armlinux.org.uk>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, David Rientjes <rientjes@google.com>, PaX Team <pageexec@freemail.hu>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, linux-arch <linux-arch@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Brad Spengler <spender@grsecurity.net>, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>T
List-Id: linux-mm.kvack.org

TWljaGFlbCBFbGxlcm1hbiA8bXBlQGVsbGVybWFuLmlkLmF1PiB3cml0ZXM6Cgo+IEtlZXMgQ29v
ayA8a2Vlc2Nvb2tAY2hyb21pdW0ub3JnPiB3cml0ZXM6Cj4KPj4gT24gRnJpLCBKdWwgOCwgMjAx
NiBhdCAxOjQxIFBNLCBLZWVzIENvb2sgPGtlZXNjb29rQGNocm9taXVtLm9yZz4gd3JvdGU6Cj4+
PiBTbywgYXMgZm91bmQgYWxyZWFkeSwgdGhlIHBvc2l0aW9uIGluIHRoZSB1c2VyY29weSBjaGVj
ayBuZWVkcyB0byBiZQo+Pj4gYnVtcGVkIGRvd24gYnkgcmVkX2xlZnRfcGFkLCB3aGljaCBpcyB3
aGF0IE1pY2hhZWwncyBmaXggZG9lcywgc28gSSdsbAo+Pj4gaW5jbHVkZSBpdCBpbiB0aGUgbmV4
dCB2ZXJzaW9uLgo+Pgo+PiBBY3R1YWxseSwgYWZ0ZXIgc29tZSBvZmZsaW5lIGNoYXRzLCBJIHRo
aW5rIHRoaXMgaXMgYmV0dGVyLCBzaW5jZSBpdAo+PiBtYWtlcyBzdXJlIHRoZSBwdHIgZG9lc24n
dCBlbmQgdXAgc29tZXdoZXJlIHdlaXJkIGJlZm9yZSB3ZSBzdGFydCB0aGUKPj4gY2FsY3VsYXRp
b25zLiBUaGlzIGxlYXZlcyB0aGUgcG9pbnRlciBhcy1pcywgYnV0IGV4cGxpY2l0bHkgaGFuZGxl
cwo+PiB0aGUgcmVkem9uZSBvbiB0aGUgb2Zmc2V0IGluc3RlYWQsIHdpdGggbm8gd3JhcHBpbmcs
IGV0YzoKPj4KPj4gICAgICAgICAvKiBGaW5kIG9mZnNldCB3aXRoaW4gb2JqZWN0LiAqLwo+PiAg
ICAgICAgIG9mZnNldCA9IChwdHIgLSBwYWdlX2FkZHJlc3MocGFnZSkpICUgcy0+c2l6ZTsKPj4K
Pj4gKyAgICAgICAvKiBBZGp1c3QgZm9yIHJlZHpvbmUgYW5kIHJlamVjdCBpZiB3aXRoaW4gdGhl
IHJlZHpvbmUuICovCj4+ICsgICAgICAgaWYgKHMtPmZsYWdzICYgU0xBQl9SRURfWk9ORSkgewo+
PiArICAgICAgICAgICAgICAgaWYgKG9mZnNldCA8IHMtPnJlZF9sZWZ0X3BhZCkKPj4gKyAgICAg
ICAgICAgICAgICAgICAgICAgcmV0dXJuIHMtPm5hbWU7Cj4+ICsgICAgICAgICAgICAgICBvZmZz
ZXQgLT0gcy0+cmVkX2xlZnRfcGFkOwo+PiArICAgICAgIH0KPj4gKwo+PiAgICAgICAgIC8qIEFs
bG93IGFkZHJlc3MgcmFuZ2UgZmFsbGluZyBlbnRpcmVseSB3aXRoaW4gb2JqZWN0IHNpemUuICov
Cj4+ICAgICAgICAgaWYgKG9mZnNldCA8PSBzLT5vYmplY3Rfc2l6ZSAmJiBuIDw9IHMtPm9iamVj
dF9zaXplIC0gb2Zmc2V0KQo+PiAgICAgICAgICAgICAgICAgcmV0dXJuIE5VTEw7Cj4KPiBUaGF0
IGZpeGVzIHRoZSBjYXNlIGZvciBtZSBpbiBrc3RybmR1cCgpLCB3aGljaCBhbGxvd3MgdGhlIHN5
c3RlbSB0byBib290LgoKVWdoLCBubyBpdCBkb2Vzbid0LCBib290ZWQgdGhlIHdyb25nIGtlcm5l
bC4KCkkgZG9uJ3Qgc2VlIHRoZSBvb3BzIGluIHN0cm5kdXBfdXNlcigpLCBidXQgaW5zdGVhZCBn
ZXQ6Cgp1c2VyY29weToga2VybmVsIG1lbW9yeSBvdmVyd3JpdGUgYXR0ZW1wdCBkZXRlY3RlZCB0
byBkMDAwMDAwMDAzNjEwMDI4IChjZnFfaW9fY3EpICg4OCBieXRlcykKQ1BVOiAxMSBQSUQ6IDEg
Q29tbTogc3lzdGVtZCBOb3QgdGFpbnRlZCA0LjcuMC1yYzMtMDAwOTgtZzA5ZDk1NTZhZTVkMS1k
aXJ0eSAjNjUKQ2FsbCBUcmFjZToKW2MwMDAwMDAxZmIwODdiZjBdIFtjMDAwMDAwMDAwOWJkYmU4
XSBkdW1wX3N0YWNrKzB4YjAvMHhmMCAodW5yZWxpYWJsZSkKW2MwMDAwMDAxZmIwODdjMzBdIFtj
MDAwMDAwMDAwMjljZjQ0XSBfX2NoZWNrX29iamVjdF9zaXplKzB4NzQvMHgzMjAKW2MwMDAwMDAx
ZmIwODdjYjBdIFtjMDAwMDAwMDAwMDVkNGQwXSBjb3B5X2Zyb21fdXNlcisweDYwLzB4ZDQKW2Mw
MDAwMDAxZmIwODdjZjBdIFtjMDAwMDAwMDAwOGIzOGY0XSBfX2dldF9maWx0ZXIrMHg3NC8weDE2
MApbYzAwMDAwMDFmYjA4N2QzMF0gW2MwMDAwMDAwMDA4YjQwOGNdIHNrX2F0dGFjaF9maWx0ZXIr
MHgyYy8weGMwCltjMDAwMDAwMWZiMDg3ZDYwXSBbYzAwMDAwMDAwMDg3MWMzNF0gc29ja19zZXRz
b2Nrb3B0KzB4OTU0LzB4YzAwCltjMDAwMDAwMWZiMDg3ZGQwXSBbYzAwMDAwMDAwMDg2YWM0NF0g
U3lTX3NldHNvY2tvcHQrMHgxMzQvMHgxNTAKW2MwMDAwMDAxZmIwODdlMzBdIFtjMDAwMDAwMDAw
MDA5MjYwXSBzeXN0ZW1fY2FsbCsweDM4LzB4MTA4Cktlcm5lbCBwYW5pYyAtIG5vdCBzeW5jaW5n
OiBBdHRlbXB0ZWQgdG8ga2lsbCBpbml0ISBleGl0Y29kZT0weDAwMDAwMDA5CgpjaGVlcnMKX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KTGludXhwcGMtZGV2
IG1haWxpbmcgbGlzdApMaW51eHBwYy1kZXZAbGlzdHMub3psYWJzLm9yZwpodHRwczovL2xpc3Rz
Lm96bGFicy5vcmcvbGlzdGluZm8vbGludXhwcGMtZGV2

From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [kernel-hardening] Re: [PATCH 9/9] mm: SLUB hardened usercopy
 support
Date: Fri, 08 Jul 2016 20:19:58 +1000
Message-ID: <3rm9Vj2RbYzDqnH@lists.ozlabs.org>
References: <CAGXu5jJbmLD-zPzJodM0=imuj-=w_s8RGP=vwtGuhmXJjQjuSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <CAGXu5jJbmLD-zPzJodM0=imuj-=w_s8RGP=vwtGuhmXJjQjuSw@mail.gmail.com>
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
To: Kees Cook <keescook@chromium.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>
Cc: linux-ia64@vger.kernel.org, Fenghua Yu <fenghua.yu@intel.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Linux-MM <linux-mm@kvack.org>, sparclinux <sparclinux@vger.kernel.org>, Jan Kara <jack@suse.cz>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, "x86@kernel.org" <x86@kernel.org>, Russell King <linux@armlinux.org.uk>, David Rientjes <rientjes@google.com>, PaX Team <pageexec@freemail.hu>, Borislav Petkov <bp@suse.de>, lin <ux-arm-kernel@lists.infradead.org>, Mathias Krause <minipli@googlemail.com>, linux-arch <linux-arch@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Brad Spengler <spender@grsecurity.net>, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, Tony Luck <tony.luck@intel.com>, Ard
List-Id: linux-mm.kvack.org

S2VlcyBDb29rIDxrZWVzY29va0BjaHJvbWl1bS5vcmc+IHdyaXRlczoKPiBPbiBUaHUsIEp1bCA3
LCAyMDE2IGF0IDEyOjM1IEFNLCBNaWNoYWVsIEVsbGVybWFuIDxtcGVAZWxsZXJtYW4uaWQuYXU+
IHdyb3RlOgo+PiBJIGdhdmUgdGhpcyBhIHF1aWNrIHNwaW4gb24gcG93ZXJwYywgaXQgYmxldyB1
cCBpbW1lZGlhdGVseSA6KQo+Cj4gV2hlZWUgOikgVGhpcyBzZXJpZXMgaXMgcmF0aGVyIGVhc3kg
dG8gdGVzdDogYmxvd3MgdXAgUkVBTExZIHF1aWNrbHkKPiBpZiBpdCdzIHdyb25nLiA7KQoKQmV0
dGVyIHRoYW4gc3VidGxlIHJhY2UgY29uZGl0aW9ucyB3aGljaCBpcyB0aGUgdXN1YWwgOikKCj4+
IGRpZmYgLS1naXQgYS9tbS9zbHViLmMgYi9tbS9zbHViLmMKPj4gaW5kZXggMGM4YWNlMDRmMDc1
Li42NjE5MWVhNDU0NWEgMTAwNjQ0Cj4+IC0tLSBhL21tL3NsdWIuYwo+PiArKysgYi9tbS9zbHVi
LmMKPj4gQEAgLTM2MzAsNiArMzYzMCw5IEBAIGNvbnN0IGNoYXIgKl9fY2hlY2tfaGVhcF9vYmpl
Y3QoY29uc3Qgdm9pZCAqcHRyLCB1bnNpZ25lZCBsb25nIG4sCj4+ICAgICAgICAgLyogRmluZCBv
YmplY3QuICovCj4+ICAgICAgICAgcyA9IHBhZ2UtPnNsYWJfY2FjaGU7Cj4+Cj4+ICsgICAgICAg
LyogU3VidHJhY3QgcmVkIHpvbmUgaWYgZW5hYmxlZCAqLwo+PiArICAgICAgIHB0ciA9IHJlc3Rv
cmVfcmVkX2xlZnQocywgcHRyKTsKPj4gKwo+Cj4gQWgsIGludGVyZXN0aW5nLiBKdXN0IHRvIG1h
a2Ugc3VyZTogeW91J3ZlIGJ1aWx0IHdpdGgKPiBDT05GSUdfU0xVQl9ERUJVRyBhbmQgZWl0aGVy
IENPTkZJR19TTFVCX0RFQlVHX09OIG9yIGJvb3RlZCB3aXRoCj4gZWl0aGVyIHNsdWJfZGVidWcg
b3Igc2x1Yl9kZWJ1Zz16ID8KClllYWggYnVpbHQgd2l0aCBDT05GSUdfU0xVQl9ERUJVR19PTiwg
YW5kIGJvb3RlZCB3aXRoIGFuZCB3aXRob3V0IHNsdWJfZGVidWcKb3B0aW9ucy4KCj4gVGhhbmtz
IGZvciB0aGUgc2x1YiBmaXghCj4KPiBJIHdvbmRlciBpZiB0aGlzIGNvZGUgc2hvdWxkIGJlIHVz
aW5nIHNpemVfZnJvbV9vYmplY3QoKSBpbnN0ZWFkIG9mIHMtPnNpemU/CgpIbW0sIG5vdCBzdXJl
LiBXaG8ncyBTTFVCIG1haW50YWluZXI/IDopCgpJIHdhcyBtb2RlbGxpbmcgaXQgb24gdGhlIGxv
Z2ljIGluIGNoZWNrX3ZhbGlkX3BvaW50ZXIoKSwgd2hpY2ggYWxzbyBkb2VzIHRoZQpyZXN0b3Jl
X3JlZF9sZWZ0KCksIGFuZCB0aGVuIGNoZWNrcyBmb3IgJSBzLT5zaXplOgoKc3RhdGljIGlubGlu
ZSBpbnQgY2hlY2tfdmFsaWRfcG9pbnRlcihzdHJ1Y3Qga21lbV9jYWNoZSAqcywKCQkJCXN0cnVj
dCBwYWdlICpwYWdlLCB2b2lkICpvYmplY3QpCnsKCXZvaWQgKmJhc2U7CgoJaWYgKCFvYmplY3Qp
CgkJcmV0dXJuIDE7CgoJYmFzZSA9IHBhZ2VfYWRkcmVzcyhwYWdlKTsKCW9iamVjdCA9IHJlc3Rv
cmVfcmVkX2xlZnQocywgb2JqZWN0KTsKCWlmIChvYmplY3QgPCBiYXNlIHx8IG9iamVjdCA+PSBi
YXNlICsgcGFnZS0+b2JqZWN0cyAqIHMtPnNpemUgfHwKCQkob2JqZWN0IC0gYmFzZSkgJSBzLT5z
aXplKSB7CgkJcmV0dXJuIDA7Cgl9CgoJcmV0dXJuIDE7Cn0KCmNoZWVycwpfX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpMaW51eHBwYy1kZXYgbWFpbGluZyBs
aXN0CkxpbnV4cHBjLWRldkBsaXN0cy5vemxhYnMub3JnCmh0dHBzOi8vbGlzdHMub3psYWJzLm9y
Zy9saXN0aW5mby9saW51eHBwYy1kZXY=

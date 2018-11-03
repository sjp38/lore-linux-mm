From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH -next 0/3] Add support for fast mremap
Date: Sat, 03 Nov 2018 10:15:11 +0100
Message-ID: <6886607.O3ZT5bM3Cy@blindfold>
References: <20181103040041.7085-1-joelaf@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <linux-snps-arc-bounces+gla-linux-snps-arc=m.gmane.org@lists.infradead.org>
In-Reply-To: <20181103040041.7085-1-joelaf@google.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-snps-arc>,
 <mailto:linux-snps-arc-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-snps-arc/>
List-Post: <mailto:linux-snps-arc@lists.infradead.org>
List-Help: <mailto:linux-snps-arc-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-snps-arc>,
 <mailto:linux-snps-arc-request@lists.infradead.org?subject=subscribe>
Sender: "linux-snps-arc" <linux-snps-arc-bounces@lists.infradead.org>
Errors-To: linux-snps-arc-bounces+gla-linux-snps-arc=m.gmane.org@lists.infradead.org
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Joel Fernandes <joelaf@google.com>, linux-mips@linux-mips.org, Rich Felker <dalias@libc.org>, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, lokeshgidra@google.com, sparclinux@vger.kernel.org, linux-riscv@lists.infradead.org, linux-ia64@vge, elfring@users.sourceforge.net, Jonas Bonn <jonas@southpole.se>, kvmarm@lists.cs.columbia.edu, dancol@google.com, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-xtensa@linux-xtensa.org, linux-hexagon@vger.kernel.org, Helge Deller <deller@gmx.de>, r.kernel.org@lithops.sigma-star.at, hughd@google.com, "James E.J. Bottomley" <jejb@parisc-linux.org>, kasan-dev@googlegroups.com
List-Id: linux-mm.kvack.org

Sm9lbCwKCkFtIFNhbXN0YWcsIDMuIE5vdmVtYmVyIDIwMTgsIDA1OjAwOjM4IENFVCBzY2hyaWVi
IEpvZWwgRmVybmFuZGVzOgo+IEhpLAo+IEhlcmUgaXMgdGhlIGxhdGVzdCAiZmFzdCBtcmVtYXAi
IHNlcmllcy4gVGhpcyBqdXN0IGEgcmVwb3N0IHdpdGggS2lyaWxsJ3MKPiBBY2tlZC1ieXMgYWRk
ZWQuIEkgd291bGQgbGlrZSB0aGlzIHRvIGJlIGNvbnNpZGVyZWQgZm9yIGxpbnV4IC1uZXh0LiAg
SSBhbHNvCj4gZHJvcHBlZCB0aGUgQ09ORklHIGVuYWJsZW1lbnQgcGF0Y2ggZm9yIGFybTY0IHNp
bmNlIEkgYW0geWV0IHRvIHRlc3QgaXQgd2l0aAo+IHRoZSBuZXcgVExCIGZsdXNoaW5nIGNvZGUg
dGhhdCBpcyBpbiB2ZXJ5IHJlY2VudCBrZXJuZWwgcmVsZWFzZXMuIChOb25lIG9mIG15Cj4gYXJt
NjQgZGV2aWNlcyBydW4gbWFpbmxpbmUgcmlnaHQgbm93Likgc28gSSB3aWxsIHBvc3QgdGhlIGFy
bTY0IGVuYWJsZW1lbnQgb25jZQo+IEkgZ2V0IHRvIHRoYXQuIFRoZSBwZXJmb3JtYW5jZSBudW1i
ZXJzIGluIHRoZSBzZXJpZXMgYXJlIGZvciB4ODYuCj4gCj4gTGlzdCBvZiBwYXRjaGVzIGluIHNl
cmllczoKPiAKPiAoMSkgbW06IHNlbGVjdCBIQVZFX01PVkVfUE1EIGluIHg4NiBmb3IgZmFzdGVy
IG1yZW1hcAo+IAo+ICgyKSBtbTogc3BlZWQgdXAgbXJlbWFwIGJ5IDIweCBvbiBsYXJnZSByZWdp
b25zICh2NCkKPiB2MS0+djI6IEFkZGVkIHN1cHBvcnQgZm9yIHBlci1hcmNoIGVuYWJsZW1lbnQg
KEtpcmlsbCBTaHV0ZW1vdikKPiB2Mi0+djM6IFVwZGF0ZWQgY29tbWl0IG1lc3NhZ2UgdG8gc3Rh
dGUgdGhlIG9wdGltaXphdGlvbiBtYXkgYWxzbwo+IAlydW4gZm9yIG5vbi10aHAgdHlwZSBvZiBz
eXN0ZW1zIChEYW5pZWwgQ29sKS4KPiB2My0+djQ6IFJlbW92ZSB1c2VsZXNzIHBtZF9sb2NrIGNo
ZWNrIChLaXJpbGwgU2h1dGVtb3YpCj4gCVJlYmFzZWQgb250b3Agb2YgTGludXMncyBtYXN0ZXIs
IHVwZGF0ZWQgcGVyZiByZXN1bHRzIGJhc2VkCj4gICAgICAgICBvbiB4ODYgdGVzdGluZy4gQWRk
ZWQgS2lyaWxsJ3MgQWNrcy4KPiAKPiAoMykgbW06IHRyZWV3aWRlOiByZW1vdmUgdW51c2VkIGFk
ZHJlc3MgYXJndW1lbnQgZnJvbSBwdGVfYWxsb2MgZnVuY3Rpb25zICh2MikKPiB2MS0+djI6IGZp
eCBhcmNoL3VtLyBwcm90b3R5cGUgd2hpY2ggd2FzIG1pc3NlZCBpbiB2MSAoQW50b24gSXZhbm92
KQo+ICAgICAgICAgdXBkYXRlIGNoYW5nZWxvZyB3aXRoIG1hbnVhbCBmaXh1cHMgZm9yIG02OGsg
YW5kIG1pY3JvYmxhemUuCj4gCj4gbm90IGluY2x1ZGVkIC0gKDQpIG1tOiBzZWxlY3QgSEFWRV9N
T1ZFX1BNRCBpbiBhcm02NCBmb3IgZmFzdGVyIG1yZW1hcAo+ICAgICBUaGlzIHBhdGNoIGlzIGRy
b3BwZWQgc2luY2UgbGFzdCBwb3N0aW5nIHBlbmRpbmcgZnVydGhlciBwZXJmb3JtYW5jZQo+ICAg
ICB0ZXN0aW5nIG9uIGFybTY0IHdpdGggbmV3IFRMQiBnYXRoZXIgdXBkYXRlcy4gU2VlIG5vdGVz
IGluIHBhdGNoCj4gICAgIHRpdGxlZCAibW06IHNwZWVkIHVwIG1yZW1hcCBieSA1MDB4IG9uIGxh
cmdlIHJlZ2lvbnMiIGZvciBtb3JlCj4gICAgIGRldGFpbHMuCj4gCgpUaGlzIGJyZWFrcyBVTUwg
YnVpbGQ6CiAgQ0MgICAgICBtbS9tcmVtYXAubwptbS9tcmVtYXAuYzogSW4gZnVuY3Rpb24g4oCY
bW92ZV9ub3JtYWxfcG1k4oCZOgptbS9tcmVtYXAuYzoyMjk6MjogZXJyb3I6IGltcGxpY2l0IGRl
Y2xhcmF0aW9uIG9mIGZ1bmN0aW9uIOKAmHNldF9wbWRfYXTigJk7IGRpZCB5b3UgbWVhbiDigJhz
ZXRfcHRlX2F04oCZPyBbLVdlcnJvcj1pbXBsaWNpdC1mdW5jdGlvbi1kZWNsYXJhdGlvbl0KICBz
ZXRfcG1kX2F0KG1tLCBuZXdfYWRkciwgbmV3X3BtZCwgcG1kKTsKICBefn5+fn5+fn5+CiAgc2V0
X3B0ZV9hdAogIENDICAgICAgY3J5cHRvL3JuZy5vCiAgQ0MgICAgICBmcy9kaXJlY3QtaW8ubwpj
YzE6IHNvbWUgd2FybmluZ3MgYmVpbmcgdHJlYXRlZCBhcyBlcnJvcnMKClRvIHRlc3QgeW91cnNl
bGYsIGp1c3QgcnVuIG9uIGEgeDg2IGJveDoKJCBtYWtlIGRlZmNvbmZpZyBBUkNIPXVtCiQgbWFr
ZSBsaW51eCBBUkNIPXVtCgpUaGFua3MsCi8vcmljaGFyZAoKCgpfX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fXwpsaW51eC1zbnBzLWFyYyBtYWlsaW5nIGxpc3QK
bGludXgtc25wcy1hcmNAbGlzdHMuaW5mcmFkZWFkLm9yZwpodHRwOi8vbGlzdHMuaW5mcmFkZWFk
Lm9yZy9tYWlsbWFuL2xpc3RpbmZvL2xpbnV4LXNucHMtYXJj

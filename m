From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 1/9] mm: Hardened usercopy
Date: Fri, 08 Jul 2016 15:34:19 +1000
Message-ID: <13684.5261244618$1467956140@news.gmane.org>
References: <1467843928-29351-1-git-send-email-keescook@chromium.org>
 <1467843928-29351-2-git-send-email-keescook@chromium.org>
 <3418914.byvl8Wuxlf@wuerfel>
 <CAGXu5jLyBfqXJKxohHiZgztRVrFyqwbta1W_Dw6KyyGM3LzshQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <CAGXu5jLyBfqXJKxohHiZgztRVrFyqwbta1W_Dw6KyyGM3LzshQ@mail.gmail.com>
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
To: Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>
Cc: nel.org@lists.ozlabs.org, Jan Kara <jack@suse.cz>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Linux-MM <linux-mm@kvack.org>, sparclinux <sparclinux@vger.kernel.org>, linux-ia64@vger.kernel.org, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, "x86@kernel.org" <x86@kernel.org>, Russell King <linux@armlinux.org.uk>, Dmitry Vyukov <dvyukov@google.com>, David Rientjes <rientjes@google.com>, PaX Team <pageexec@freemail.hu>, Mathias Krause <minipli@googlemail.com>, linux-arch <linux-arch@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Tony Luck <tony.luck@intel.com>, Andy Lutomirski <luto@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>Laura Abbott <lab>
List-Id: linux-mm.kvack.org

S2VlcyBDb29rIDxrZWVzY29va0BjaHJvbWl1bS5vcmc+IHdyaXRlczoKCj4gT24gVGh1LCBKdWwg
NywgMjAxNiBhdCA0OjAxIEFNLCBBcm5kIEJlcmdtYW5uIDxhcm5kQGFybmRiLmRlPiB3cm90ZToK
Pj4gT24gV2VkbmVzZGF5LCBKdWx5IDYsIDIwMTYgMzoyNToyMCBQTSBDRVNUIEtlZXMgQ29vayB3
cm90ZToKPj4+ICsKPj4+ICsgICAgIC8qIEFsbG93IGtlcm5lbCByb2RhdGEgcmVnaW9uIChpZiBu
b3QgbWFya2VkIGFzIFJlc2VydmVkKS4gKi8KPj4+ICsgICAgIGlmIChwdHIgPj0gKGNvbnN0IHZv
aWQgKilfX3N0YXJ0X3JvZGF0YSAmJgo+Pj4gKyAgICAgICAgIGVuZCA8PSAoY29uc3Qgdm9pZCAq
KV9fZW5kX3JvZGF0YSkKPj4+ICsgICAgICAgICAgICAgcmV0dXJuIE5VTEw7Cj4+Cj4+IFNob3Vs
ZCB3ZSBleHBsaWNpdGx5IGZvcmJpZCB3cml0aW5nIHRvIHJvZGF0YSwgb3IgaXMgaXQgZW5vdWdo
IHRvCj4+IHJlbHkgb24gcGFnZSBwcm90ZWN0aW9uIGhlcmU/Cj4KPiBIbSwgaW50ZXJlc3Rpbmcu
IFRoYXQncyBhIHZlcnkgc21hbGwgY2hlY2sgdG8gYWRkLiBNeSBrbmVlLWplcmsgaXMgdG8KPiBq
dXN0IGxlYXZlIGl0IHVwIHRvIHBhZ2UgcHJvdGVjdGlvbi4gSSdtIG9uIHRoZSBmZW5jZS4gOikK
ClRoZXJlIGFyZSBwbGF0Zm9ybXMgdGhhdCBkb24ndCBoYXZlIHBhZ2UgcHJvdGVjdGlvbiwgc28g
aXQgd291bGQgYmUgbmljZQppZiB0aGV5IGNvdWxkIGF0IGxlYXN0IG9wdC1pbiB0byBjaGVja2lu
ZyBmb3IgaXQgaGVyZS4KCmNoZWVycwpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fXwpMaW51eHBwYy1kZXYgbWFpbGluZyBsaXN0CkxpbnV4cHBjLWRldkBsaXN0
cy5vemxhYnMub3JnCmh0dHBzOi8vbGlzdHMub3psYWJzLm9yZy9saXN0aW5mby9saW51eHBwYy1k
ZXY=

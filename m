From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [kernel-hardening] [PATCH v2 11/11] mm: SLUB hardened usercopy
 support
Date: Thu, 14 Jul 2016 20:07:01 +1000
Message-ID: <7796.60821795023$1468490886@news.gmane.org>
References: <1468446964-22213-1-git-send-email-keescook@chromium.org>
 <1468446964-22213-12-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1468446964-22213-12-git-send-email-keescook@chromium.org>
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
To: linux-kernel@vger.kernel.org
Cc: Jan Kara <jack@suse.cz>, kernel-hardening@lists.openwall.com, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch@vger.kernel.org, x86@kernel.org, Russell King <linux@armlinux.org.uk>, linux-arm-kernel@lists.infradead.org, PaX Team <pageexec@freemail.hu>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Fenghua Yu <fenghua.yu@intel.com>, Rik van Riel <riel@redhat.com>, Kees Cook <keescook@chromium.org>, David Rientjes <rientjes@google.com>, Tony Luck <tony.luck@intel.com>, Andy Lutomirski <luto@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, Brad Spengler <spender@grsecurity.net>, Ard
List-Id: linux-mm.kvack.org

S2VlcyBDb29rIDxrZWVzY29va0BjaHJvbWl1bS5vcmc+IHdyaXRlczoKCj4gVW5kZXIgQ09ORklH
X0hBUkRFTkVEX1VTRVJDT1BZLCB0aGlzIGFkZHMgb2JqZWN0IHNpemUgY2hlY2tpbmcgdG8gdGhl
Cj4gU0xVQiBhbGxvY2F0b3IgdG8gY2F0Y2ggYW55IGNvcGllcyB0aGF0IG1heSBzcGFuIG9iamVj
dHMuIEluY2x1ZGVzIGEKPiByZWR6b25lIGhhbmRsaW5nIGZpeCBmcm9tIE1pY2hhZWwgRWxsZXJt
YW4uCgpBY3R1YWxseSBJIHRoaW5rIHlvdSB3cm90ZSB0aGUgZml4LCBJIGp1c3QgcG9pbnRlZCB5
b3UgaW4gdGhhdApkaXJlY3Rpb24uIEJ1dCBhbnl3YXksIHRoaXMgd29ya3MgZm9yIG1lLCBzbyBp
ZiB5b3UgbGlrZToKClRlc3RlZC1ieTogTWljaGFlbCBFbGxlcm1hbiA8bXBlQGVsbGVybWFuLmlk
LmF1PgoKY2hlZXJzCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fCkxpbnV4cHBjLWRldiBtYWlsaW5nIGxpc3QKTGludXhwcGMtZGV2QGxpc3RzLm96bGFicy5v
cmcKaHR0cHM6Ly9saXN0cy5vemxhYnMub3JnL2xpc3RpbmZvL2xpbnV4cHBjLWRldg==

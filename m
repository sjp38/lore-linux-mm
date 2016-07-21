From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v3 02/11] mm: Hardened usercopy
Date: Thu, 21 Jul 2016 16:52:09 +1000
Message-ID: <16654.7783920125$1469084006@news.gmane.org>
References: <1468619065-3222-1-git-send-email-keescook@chromium.org>
 <1468619065-3222-3-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1468619065-3222-3-git-send-email-keescook@chromium.org>
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
Cc: Jan Kara <jack@suse.cz>, kernel-hardening@lists.openwall.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch@vger.kernel.org, x86@kernel.org, Russell King <linux@armlinux.org.uk>, linux-arm-kernel@lists.infradead.org, Catalin Marinas <catalin.marinas@arm.com>, PaX Team <pageexec@freemail.hu>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Fenghua Yu <fenghua.yu@intel.com>, Rik van Riel <riel@redhat.com>, Kees Cook <keescook@chromium.org>, David Rientjes <rientjes@google.com>, Tony Luck <tony.luck@intel.com>, Andy Lutomirski <luto@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, Brad
List-Id: linux-mm.kvack.org

S2VlcyBDb29rIDxrZWVzY29va0BjaHJvbWl1bS5vcmc+IHdyaXRlczoKCj4gZGlmZiAtLWdpdCBh
L21tL3VzZXJjb3B5LmMgYi9tbS91c2VyY29weS5jCj4gbmV3IGZpbGUgbW9kZSAxMDA2NDQKPiBp
bmRleCAwMDAwMDAwMDAwMDAuLmU0YmY0ZTdjY2RmNgo+IC0tLSAvZGV2L251bGwKPiArKysgYi9t
bS91c2VyY29weS5jCj4gQEAgLTAsMCArMSwyMzQgQEAKLi4uCj4gKwo+ICsvKgo+ICsgKiBDaGVj
a3MgaWYgYSBnaXZlbiBwb2ludGVyIGFuZCBsZW5ndGggaXMgY29udGFpbmVkIGJ5IHRoZSBjdXJy
ZW50Cj4gKyAqIHN0YWNrIGZyYW1lIChpZiBwb3NzaWJsZSkuCj4gKyAqCj4gKyAqCTA6IG5vdCBh
dCBhbGwgb24gdGhlIHN0YWNrCj4gKyAqCTE6IGZ1bGx5IHdpdGhpbiBhIHZhbGlkIHN0YWNrIGZy
YW1lCj4gKyAqCTI6IGZ1bGx5IG9uIHRoZSBzdGFjayAod2hlbiBjYW4ndCBkbyBmcmFtZS1jaGVj
a2luZykKPiArICoJLTE6IGVycm9yIGNvbmRpdGlvbiAoaW52YWxpZCBzdGFjayBwb3NpdGlvbiBv
ciBiYWQgc3RhY2sgZnJhbWUpCj4gKyAqLwo+ICtzdGF0aWMgbm9pbmxpbmUgaW50IGNoZWNrX3N0
YWNrX29iamVjdChjb25zdCB2b2lkICpvYmosIHVuc2lnbmVkIGxvbmcgbGVuKQo+ICt7Cj4gKwlj
b25zdCB2b2lkICogY29uc3Qgc3RhY2sgPSB0YXNrX3N0YWNrX3BhZ2UoY3VycmVudCk7Cj4gKwlj
b25zdCB2b2lkICogY29uc3Qgc3RhY2tlbmQgPSBzdGFjayArIFRIUkVBRF9TSVpFOwoKVGhhdCBh
bGxvd3MgYWNjZXNzIHRvIHRoZSBlbnRpcmUgc3RhY2ssIGluY2x1ZGluZyB0aGUgc3RydWN0IHRo
cmVhZF9pbmZvLAppcyB0aGF0IHdoYXQgd2Ugd2FudCAtIGl0IHNlZW1zIGRhbmdlcm91cz8gT3Ig
ZGlkIEkgbWlzcyBhIGNoZWNrCnNvbWV3aGVyZSBlbHNlPwoKV2UgaGF2ZSBlbmRfb2Zfc3RhY2so
KSB3aGljaCBjb21wdXRlcyB0aGUgZW5kIG9mIHRoZSBzdGFjayB0YWtpbmcKdGhyZWFkX2luZm8g
aW50byBhY2NvdW50IChlbmQgYmVpbmcgdGhlIG9wcG9zaXRlIG9mIHlvdXIgZW5kIGFib3ZlKS4K
CmNoZWVycwpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpM
aW51eHBwYy1kZXYgbWFpbGluZyBsaXN0CkxpbnV4cHBjLWRldkBsaXN0cy5vemxhYnMub3JnCmh0
dHBzOi8vbGlzdHMub3psYWJzLm9yZy9saXN0aW5mby9saW51eHBwYy1kZXY=

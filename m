From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH 0/6] arm64: untag user pointers passed to the kernel
Date: Wed, 18 Apr 2018 20:53:09 +0200
Message-ID: <cover.1524077494.git.andreyknvl__34633.8333948099$1524077781$gmane$org@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Jonathan Corbet <corbet@lwn.net>, Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrey Konovalov <andreyknvl@google.com>, James Morse <james.morse@arm.com>, Kees Cook <keescook@chromium.org>, Bart Van Assche <bart.vanassche@wdc.com>, Kate Stewart <kstewart@linuxfoundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Thomas Gleixner <tglx@linutronix.de>, Philippe Ombredanne <pombredanne@nexb.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Zi Yan <zi.yan@cs.rutgers.edu>, linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.orglin
Cc: Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Lee Smith <Lee.Smith@arm.com>, Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Evgeniy Stepanov <eugenis@google.com>
List-Id: linux-mm.kvack.org

SGkhCgphcm02NCBoYXMgYSBmZWF0dXJlIGNhbGxlZCBUb3AgQnl0ZSBJZ25vcmUsIHdoaWNoIGFs
bG93cyB0byBlbWJlZCBwb2ludGVyCnRhZ3MgaW50byB0aGUgdG9wIGJ5dGUgb2YgZWFjaCBwb2lu
dGVyLiBVc2Vyc3BhY2UgcHJvZ3JhbXMgKHN1Y2ggYXMKSFdBU2FuLCBhIG1lbW9yeSBkZWJ1Z2dp
bmcgdG9vbCBbMV0pIG1pZ2h0IHVzZSB0aGlzIGZlYXR1cmUgYW5kIHBhc3MKdGFnZ2VkIHVzZXIg
cG9pbnRlcnMgdG8gdGhlIGtlcm5lbCB0aHJvdWdoIHN5c2NhbGxzIG9yIG90aGVyIGludGVyZmFj
ZXMuCgpUaGlzIHBhdGNoIG1ha2VzIGEgZmV3IG9mIHRoZSBrZXJuZWwgaW50ZXJmYWNlcyBhY2Nl
cHQgdGFnZ2VkIHVzZXIKcG9pbnRlcnMuIFRoZSBrZXJuZWwgaXMgYWxyZWFkeSBhYmxlIHRvIGhh
bmRsZSB1c2VyIGZhdWx0cyB3aXRoIHRhZ2dlZApwb2ludGVycyBhbmQgaGFzIHRoZSB1bnRhZ2dl
ZF9hZGRyIG1hY3JvLCB3aGljaCB0aGlzIHBhdGNoc2V0IHJldXNlcy4KCldlJ3JlIG5vdCB0cnlp
bmcgdG8gY292ZXIgYWxsIHBvc3NpYmxlIHdheXMgdGhlIGtlcm5lbCBhY2NlcHRzIHVzZXIKcG9p
bnRlcnMgaW4gb25lIHBhdGNoc2V0LCBzbyB0aGlzIG9uZSBzaG91bGQgYmUgY29uc2lkZXJlZCBh
cyBhIHN0YXJ0LgoKVGhhbmtzIQoKWzFdIGh0dHA6Ly9jbGFuZy5sbHZtLm9yZy9kb2NzL0hhcmR3
YXJlQXNzaXN0ZWRBZGRyZXNzU2FuaXRpemVyRGVzaWduLmh0bWwKCkNoYW5nZXMgaW4gdjE6Ci0g
UmViYXNlZCBvbnRvIDQuMTctcmMxLgoKQ2hhbmdlcyBpbiBSRkMgdjI6Ci0gQWRkZWQgIiNpZm5k
ZWYgdW50YWdnZWRfYWRkci4uLiIgZmFsbGJhY2sgaW4gbGludXgvdWFjY2Vzcy5oIGluc3RlYWQg
b2YKICBkZWZpbmluZyBpdCBmb3IgZWFjaCBhcmNoIGluZGl2aWR1YWxseS4KLSBVcGRhdGVkIERv
Y3VtZW50YXRpb24vYXJtNjQvdGFnZ2VkLXBvaW50ZXJzLnR4dC4KLSBEcm9wcGVkIOKAnG1tLCBh
cm02NDogdW50YWcgdXNlciBhZGRyZXNzZXMgaW4gbWVtb3J5IHN5c2NhbGxz4oCdLgotIFJlYmFz
ZWQgb250byAzZWIyY2U4MiAoNC4xNi1yYzcpLgoKQW5kcmV5IEtvbm92YWxvdiAoNik6CiAgYXJt
NjQ6IGFkZCB0eXBlIGNhc3RzIHRvIHVudGFnZ2VkX2FkZHIgbWFjcm8KICB1YWNjZXNzOiBhZGQg
dW50YWdnZWRfYWRkciBkZWZpbml0aW9uIGZvciBvdGhlciBhcmNoZXMKICBhcm02NDogdW50YWcg
dXNlciBhZGRyZXNzZXMgaW4gY29weV9mcm9tX3VzZXIgYW5kIG90aGVycwogIG1tLCBhcm02NDog
dW50YWcgdXNlciBhZGRyZXNzZXMgaW4gbW0vZ3VwLmMKICBsaWIsIGFybTY0OiB1bnRhZyBhZGRy
cyBwYXNzZWQgdG8gc3RybmNweV9mcm9tX3VzZXIgYW5kIHN0cm5sZW5fdXNlcgogIGFybTY0OiB1
cGRhdGUgRG9jdW1lbnRhdGlvbi9hcm02NC90YWdnZWQtcG9pbnRlcnMudHh0CgogRG9jdW1lbnRh
dGlvbi9hcm02NC90YWdnZWQtcG9pbnRlcnMudHh0IHwgIDUgKysrLS0KIGFyY2gvYXJtNjQvaW5j
bHVkZS9hc20vdWFjY2Vzcy5oICAgICAgICB8ICA5ICsrKysrKystLQogaW5jbHVkZS9saW51eC91
YWNjZXNzLmggICAgICAgICAgICAgICAgIHwgIDQgKysrKwogbGliL3N0cm5jcHlfZnJvbV91c2Vy
LmMgICAgICAgICAgICAgICAgIHwgIDIgKysKIGxpYi9zdHJubGVuX3VzZXIuYyAgICAgICAgICAg
ICAgICAgICAgICB8ICAyICsrCiBtbS9ndXAuYyAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgfCAxMiArKysrKysrKysrKysKIDYgZmlsZXMgY2hhbmdlZCwgMzAgaW5zZXJ0aW9ucygrKSwg
NCBkZWxldGlvbnMoLSkKCi0tIAoyLjE3LjAuNDg0LmcwYzg3MjYzMThjLWdvb2cKCgpfX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpsaW51eC1hcm0ta2VybmVs
IG1haWxpbmcgbGlzdApsaW51eC1hcm0ta2VybmVsQGxpc3RzLmluZnJhZGVhZC5vcmcKaHR0cDov
L2xpc3RzLmluZnJhZGVhZC5vcmcvbWFpbG1hbi9saXN0aW5mby9saW51eC1hcm0ta2VybmVsCg==

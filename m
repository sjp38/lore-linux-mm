From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v2 0/6] arm64: untag user pointers passed to the kernel
Date: Thu,  3 May 2018 16:15:38 +0200
Message-ID: <cover.1525356769.git.andreyknvl__2811.33718458495$1525356849$gmane$org@google.com>
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
Cc: Chintan Pandya <cpandya@codeaurora.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Lee Smith <Lee.Smith@arm.com>, Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Evgeniy Stepanov <eugenis@google.com>
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
YXJlQXNzaXN0ZWRBZGRyZXNzU2FuaXRpemVyRGVzaWduLmh0bWwKCkNoYW5nZXMgaW4gdjI6Ci0g
UmViYXNlZCBvbnRvIDJkNjE4YmRmICg0LjE3LXJjMyspLgotIFJlbW92ZWQgZXhjZXNzaXZlIHVu
dGFnZ2luZyBpbiBndXAuYy4KLSBSZW1vdmVkIHVudGFnZ2luZyBwb2ludGVycyByZXR1cm5lZCBm
cm9tIF9fdWFjY2Vzc19tYXNrX3B0ci4KCkNoYW5nZXMgaW4gdjE6Ci0gUmViYXNlZCBvbnRvIDQu
MTctcmMxLgoKQ2hhbmdlcyBpbiBSRkMgdjI6Ci0gQWRkZWQgIiNpZm5kZWYgdW50YWdnZWRfYWRk
ci4uLiIgZmFsbGJhY2sgaW4gbGludXgvdWFjY2Vzcy5oIGluc3RlYWQgb2YKICBkZWZpbmluZyBp
dCBmb3IgZWFjaCBhcmNoIGluZGl2aWR1YWxseS4KLSBVcGRhdGVkIERvY3VtZW50YXRpb24vYXJt
NjQvdGFnZ2VkLXBvaW50ZXJzLnR4dC4KLSBEcm9wcGVkIOKAnG1tLCBhcm02NDogdW50YWcgdXNl
ciBhZGRyZXNzZXMgaW4gbWVtb3J5IHN5c2NhbGxz4oCdLgotIFJlYmFzZWQgb250byAzZWIyY2U4
MiAoNC4xNi1yYzcpLgoKQW5kcmV5IEtvbm92YWxvdiAoNik6CiAgYXJtNjQ6IGFkZCB0eXBlIGNh
c3RzIHRvIHVudGFnZ2VkX2FkZHIgbWFjcm8KICB1YWNjZXNzOiBhZGQgdW50YWdnZWRfYWRkciBk
ZWZpbml0aW9uIGZvciBvdGhlciBhcmNoZXMKICBhcm02NDogdW50YWcgdXNlciBhZGRyZXNzZXMg
aW4gYWNjZXNzX29rIGFuZCBfX3VhY2Nlc3NfbWFza19wdHIKICBtbSwgYXJtNjQ6IHVudGFnIHVz
ZXIgYWRkcmVzc2VzIGluIG1tL2d1cC5jCiAgbGliLCBhcm02NDogdW50YWcgYWRkcnMgcGFzc2Vk
IHRvIHN0cm5jcHlfZnJvbV91c2VyIGFuZCBzdHJubGVuX3VzZXIKICBhcm02NDogdXBkYXRlIERv
Y3VtZW50YXRpb24vYXJtNjQvdGFnZ2VkLXBvaW50ZXJzLnR4dAoKIERvY3VtZW50YXRpb24vYXJt
NjQvdGFnZ2VkLXBvaW50ZXJzLnR4dCB8ICA1ICsrKy0tCiBhcmNoL2FybTY0L2luY2x1ZGUvYXNt
L3VhY2Nlc3MuaCAgICAgICAgfCAxNCArKysrKysrKystLS0tLQogaW5jbHVkZS9saW51eC91YWNj
ZXNzLmggICAgICAgICAgICAgICAgIHwgIDQgKysrKwogbGliL3N0cm5jcHlfZnJvbV91c2VyLmMg
ICAgICAgICAgICAgICAgIHwgIDIgKysKIGxpYi9zdHJubGVuX3VzZXIuYyAgICAgICAgICAgICAg
ICAgICAgICB8ICAyICsrCiBtbS9ndXAuYyAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
fCAgNCArKysrCiA2IGZpbGVzIGNoYW5nZWQsIDI0IGluc2VydGlvbnMoKyksIDcgZGVsZXRpb25z
KC0pCgotLSAKMi4xNy4wLjQ0MS5nYjQ2ZmU2MGUxZC1nb29nCgoKX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX18KbGludXgtYXJtLWtlcm5lbCBtYWlsaW5nIGxp
c3QKbGludXgtYXJtLWtlcm5lbEBsaXN0cy5pbmZyYWRlYWQub3JnCmh0dHA6Ly9saXN0cy5pbmZy
YWRlYWQub3JnL21haWxtYW4vbGlzdGluZm8vbGludXgtYXJtLWtlcm5lbAo=

From: "Srivatsa S. Bhat" <srivatsa@csail.mit.edu>
Subject: [RESEND] Spectre-v2 (IBPB/IBRS) and SSBD fixes for 4.4.y
Date: Sat, 14 Jul 2018 02:25:43 -0700
Message-ID: <153156030832.10043.13438231886571087086.stgit@srivatsa-ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <xen-devel-bounces@lists.xenproject.org>
List-Unsubscribe: <https://lists.xenproject.org/mailman/options/xen-devel>,
 <mailto:xen-devel-request@lists.xenproject.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xenproject.org>
List-Help: <mailto:xen-devel-request@lists.xenproject.org?subject=help>
List-Subscribe: <https://lists.xenproject.org/mailman/listinfo/xen-devel>,
 <mailto:xen-devel-request@lists.xenproject.org?subject=subscribe>
Errors-To: xen-devel-bounces@lists.xenproject.org
Sender: "Xen-devel" <xen-devel-bounces@lists.xenproject.org>
To: gregkh@linuxfoundation.org, stable@vger.kernel.org
Cc: Dave Hansen <dave@sr71.net>, srivatsa@csail.mit.edu, Wanpeng Li <kernellwp@gmail.com>, Andi Kleen <ak@linux.intel.com>, linux-tip-commits@vger.kernel.org, Piotr Luc <piotr.luc@intel.com>, Mel Gorman <mgorman@suse.de>, arjan.van.de.ven@intel.com, xen-devel@lists.xenproject.org, Alexander Sergeyev <sergeev917@gmail.com>, Brian Gerst <brgerst@gmail.com>, luto@kernel.org, =?utf-8?q?Micka=C3=ABl?= =?utf-8?q?Sala=C3=BCn?= <mic@digikod.net>, Thomas Gleixner <tglx@linutronix.de>, Joe Konno <joe.konno@linux.intel.com>, Laura Abbott <labbott@fedoraproject.org>, Will Drewry <wad@chromium.org>, Jiri Kosina <jkosina@suse.cz>, linux-kernel@vger.kernel.org, Jia Zhang <qianyue.zj@alibaba-inc.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Woodhouse <dwmw@amazon.co.uk>, KarimAllah Ahmed <karahmed@amazon.de>, Dave Hansen <dave.hansen>
List-Id: linux-mm.kvack.org

SGkgR3JlZywKClRoaXMgcGF0Y2ggc2VyaWVzIGlzIGEgYmFja3BvcnQgb2YgdGhlIFNwZWN0cmUt
djIgZml4ZXMgKElCUEIvSUJSUykKYW5kIHBhdGNoZXMgZm9yIHRoZSBTcGVjdWxhdGl2ZSBTdG9y
ZSBCeXBhc3MgdnVsbmVyYWJpbGl0eSB0byA0LjQueQoodGhleSBhcHBseSBjbGVhbmx5IG9uIHRv
cCBvZiA0LjQuMTQwKS4KCkkgdXNlZCA0LjkueSBhcyBteSByZWZlcmVuY2Ugd2hlbiBiYWNrcG9y
dGluZyB0byA0LjQueSAoYXMgSSB0aG91Z2h0CnRoYXQgd291bGQgbWluaW1pemUgdGhlIGFtb3Vu
dCBvZiBmaXhpbmcgdXAgbmVjZXNzYXJ5KS4gVW5mb3J0dW5hdGVseQpJIGhhZCB0byBza2lwIHRo
ZSBLVk0gZml4ZXMgZm9yIHRoZXNlIHZ1bG5lcmFiaWxpdGllcywgYXMgdGhlIEtWTQpjb2RlYmFz
ZSBpcyBkcmFzdGljYWxseSBkaWZmZXJlbnQgaW4gNC40IGFzIGNvbXBhcmVkIHRvIDQuOS4gKEkg
dHJpZWQKbXkgYmVzdCB0byBiYWNrcG9ydCB0aGVtIGluaXRpYWxseSwgYnV0IHdhc24ndCBjb25m
aWRlbnQgdGhhdCB0aGV5CndlcmUgY29ycmVjdCwgc28gSSBkZWNpZGVkIHRvIGRyb3AgdGhlbSBm
cm9tIHRoaXMgc2VyaWVzKS4KCllvdSdsbCBub3RpY2UgdGhhdCB0aGUgaW5pdGlhbCBmZXcgcGF0
Y2hlcyBpbiB0aGlzIHNlcmllcyBpbmNsdWRlCmNsZWFudXBzIGV0Yy4sIHRoYXQgYXJlIG5vbi1j
cml0aWNhbCB0byBJQlBCL0lCUlMvU1NCRC4gTW9zdCBvZiB0aGVzZQpwYXRjaGVzIGFyZSBhaW1l
ZCBhdCBnZXR0aW5nIHRoZSBjcHVmZWF0dXJlLmggdnMgY3B1ZmVhdHVyZXMuaCBzcGxpdAppbnRv
IDQuNCwgc2luY2UgYSBsb3Qgb2YgdGhlIHN1YnNlcXVlbnQgcGF0Y2hlcyB1cGRhdGUgdGhlc2Ug
aGVhZGVycy4KT24gbXkgZmlyc3QgYXR0ZW1wdCB0byBiYWNrcG9ydCB0aGVzZSBwYXRjaGVzIHRv
IDQuNC55LCBJIGhhZCBhY3R1YWxseQp0cmllZCB0byBkbyBhbGwgdGhlIHVwZGF0ZXMgb24gdGhl
IGNwdWZlYXR1cmUuaCBmaWxlIGl0c2VsZiwgYnV0IGl0CnN0YXJ0ZWQgZ2V0dGluZyB2ZXJ5IGN1
bWJlcnNvbWUsIHNvIEkgcmVzb3J0ZWQgdG8gYmFja3BvcnRpbmcgdGhlCmNwdWZlYXR1cmUuaCB2
cyBjcHVmZWF0dXJlcy5oIHNwbGl0IGFuZCB0aGVpciBkZXBlbmRlbmNpZXMgYXMgd2VsbC4gSQp0
aGluayBhcGFydCBmcm9tIHRoZXNlIGluaXRpYWwgcGF0Y2hlcywgdGhlIHJlc3Qgb2YgdGhlIHBh
dGNoc2V0CmRvZXNuJ3QgaGF2ZSBhbGwgdGhhdCBtdWNoIG5vaXNlLiAKClRoaXMgcGF0Y2hzZXQg
aGFzIGJlZW4gdGVzdGVkIG9uIGJvdGggSW50ZWwgYW5kIEFNRCBtYWNoaW5lcyAoSW50ZWwKWGVv
biBDUFUgRTUtMjY2MCB2NCBhbmQgQU1EIEVQWUMgNzI4MSAxNi1Db3JlIFByb2Nlc3NvciwgcmVz
cGVjdGl2ZWx5KQp3aXRoIHVwZGF0ZWQgbWljcm9jb2RlLiBBbGwgdGhlIHBhdGNoIGJhY2twb3J0
cyBoYXZlIGJlZW4KaW5kZXBlbmRlbnRseSByZXZpZXdlZCBieSBNYXR0IEhlbHNsZXksIEFsZXhl
eSBNYWtoYWxvdiBhbmQgQm8gR2FuLgoKSSB3b3VsZCBhcHByZWNpYXRlIGlmIHlvdSBjb3VsZCBr
aW5kbHkgY29uc2lkZXIgdGhlc2UgcGF0Y2hlcyBmb3IKcmV2aWV3IGFuZCBpbmNsdXNpb24gaW4g
YSBmdXR1cmUgNC40LnkgcmVsZWFzZS4KClRoYW5rIHlvdSB2ZXJ5IG11Y2ghCgpSZWdhcmRzLApT
cml2YXRzYQpWTXdhcmUgUGhvdG9uIE9TCgpQLlMuIFRoaXMgcGF0Y2hzZXQgaXMgYWxzbyBhdmFp
bGFibGUgaW4gdGhlIGZvbGxvd2luZyByZXBvIGlmIGFueW9uZQogICAgIGlzIGludGVyZXN0ZWQg
aW4gZ2l2aW5nIGl0IGEgdHJ5OgoKaHR0cHM6Ly9naXRodWIuY29tL3NyaXZhdHNhYmhhdC9saW51
eC1zdGFibGUgc3BlY3RyZS12Mi1maXhlcy1ub2t2bS00LjQuMTQwCgoKX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KWGVuLWRldmVsIG1haWxpbmcgbGlzdApY
ZW4tZGV2ZWxAbGlzdHMueGVucHJvamVjdC5vcmcKaHR0cHM6Ly9saXN0cy54ZW5wcm9qZWN0Lm9y
Zy9tYWlsbWFuL2xpc3RpbmZvL3hlbi1kZXZlbA==

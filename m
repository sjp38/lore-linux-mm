From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH] mm: kill kmemcheck
Date: Thu, 12 Mar 2015 14:49:52 +1100
Message-ID: <1426132192.25936.7.camel@ellerman.id.au>
References: <1426074547-21888-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1426074547-21888-1-git-send-email-sasha.levin@oracle.com>
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
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Geert Uytterhoeven <geert+renesas@glider.be>, "open list:SUPERH" <linux-sh@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Mackerras <paulus@samba.org>, Pavel Machek <pavel@ucw.cz>, Miklos Szeredi <mszeredi@suse.cz>, Christoph Lameter <cl@linux.com>, Marek Szyprowski <m.szyprowski@samsung.com>, "open list:GENERIC INCLUDE/A..." <linux-arch@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Russell King <linux@arm.linux.org.uk>, Jingoo Han <jg1.han@samsung.com>, James Morris <jmorris@namei.org>, Chris Bainbridge <chris.bainbridge@gmail.com>, Antti Palosaari <crope@iki.fi>, Mel Gorman <mgorman@suse.de>, Ritesh Harjani <ritesh.harjani@gmail.com>, Shaohua Li <shli@kernel.org>, Alexander Duyck <alexander.h.duyck@intel.com>, Wang Nan <wangnan0@huawei>
List-Id: linux-mm.kvack.org

T24gV2VkLCAyMDE1LTAzLTExIGF0IDA3OjQzIC0wNDAwLCBTYXNoYSBMZXZpbiB3cm90ZToKPiBB
cyBkaXNjdXNzZWQgb24gTFNGL01NLCBraWxsIGttZW1jaGVjay4KPiAKPiBLQVNhbiBpcyBhIHJl
cGxhY2VtZW50IHRoYXQgaXMgYWJsZSB0byB3b3JrIHdpdGhvdXQgdGhlIGxpbWl0YXRpb24gb2YK
PiBrbWVtY2hlY2sgKHNpbmdsZSBDUFUsIHNsb3cpLiBLQVNhbiBpcyBhbHJlYWR5IHVwc3RyZWFt
Lgo+IAo+IFdlIGFyZSBhbHNvIG5vdCBhd2FyZSBvZiBhbnkgdXNlcnMgb2Yga21lbWNoZWNrIChv
ciB1c2VycyB3aG8gZG9uJ3QgY29uc2lkZXIKPiBLQVNhbiBhcyBhIHN1aXRhYmxlIHJlcGxhY2Vt
ZW50KS4KCkZyb20gRG9jdW1lbnRhdGlvbi9rYXNhbi50eHQ6CgogICAgdGhlcmVmb3JlIHlvdSB3
aWxsIG5lZWQgYSBjZXJ0YWluIHZlcnNpb24gb2YgR0NDID4gNC45LjIKCkFGQUlLIGdjYyA0Ljku
MyBoYXNuJ3QgYmVlbiByZWxlYXNlZCB5ZXQuIChPciBkb2VzIGl0IG1lYW4gPj0gNC45LjIgPykK
CkNhbiB3ZSBwZXJoYXBzIHdhaXQgdW50aWwgdGhlcmUgaXMgYSByZWxlYXNlZCB2ZXJzaW9uIG9m
IEdDQyB0aGF0IHN1cHBvcnRzCktBU2FuPyBBbmQgbWF5YmUgdGhlbiBhIHRvdWNoIGxvbmdlciBz
byBmb2xrcyBjYW4gdGVzdCBpdCB3b3JrcyBvbiB0aGVpcgpwbGF0Zm9ybXM/CgpjaGVlcnMKCgpf
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpMaW51eHBwYy1k
ZXYgbWFpbGluZyBsaXN0CkxpbnV4cHBjLWRldkBsaXN0cy5vemxhYnMub3JnCmh0dHBzOi8vbGlz
dHMub3psYWJzLm9yZy9saXN0aW5mby9saW51eHBwYy1kZXY=

From: Sasha Levin <sasha.levin@oracle.com>
Subject: Re: [PATCH] mm: kill kmemcheck
Date: Thu, 12 Mar 2015 08:40:22 -0400
Message-ID: <55018936.5080805@oracle.com>
References: <1426074547-21888-1-git-send-email-sasha.levin@oracle.com>
 <1426132192.25936.7.camel@ellerman.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1426132192.25936.7.camel@ellerman.id.au>
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
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Geert Uytterhoeven <geert+renesas@glider.be>, SUPERH <linux-sh@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Mackerras <paulus@samba.org>, Pavel Machek <pavel@ucw.cz>, Miklos Szeredi <mszeredi@suse.cz>, Christoph Lameter <cl@linux.com>, Marek Szyprowski <m.szyprowski@samsung.com>, "open list:GENERIC INCLUDE/A..." <linux-arch@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Russell King <linux@arm.linux.org.uk>, Jingoo Han <jg1.han@samsung.com>, James Morris <jmorris@namei.org>, Chris Bainbridge <chris.bainbridge@gmail.com>, Antti Palosaari <crope@iki.fi>, Mel Gorman <mgorman@suse.de>, Ritesh Harjani <ritesh.harjani@gmail.com>, Shaohua Li <shli@kernel.org>, Alexander Duyck <alexander.h.duyck@intel.com>, Wang Nan <wangnan0@huawei.com>, Jiri
List-Id: linux-mm.kvack.org

T24gMDMvMTEvMjAxNSAxMTo0OSBQTSwgTWljaGFlbCBFbGxlcm1hbiB3cm90ZToKPiBPbiBXZWQs
IDIwMTUtMDMtMTEgYXQgMDc6NDMgLTA0MDAsIFNhc2hhIExldmluIHdyb3RlOgo+PiBBcyBkaXNj
dXNzZWQgb24gTFNGL01NLCBraWxsIGttZW1jaGVjay4KPj4KPj4gS0FTYW4gaXMgYSByZXBsYWNl
bWVudCB0aGF0IGlzIGFibGUgdG8gd29yayB3aXRob3V0IHRoZSBsaW1pdGF0aW9uIG9mCj4+IGtt
ZW1jaGVjayAoc2luZ2xlIENQVSwgc2xvdykuIEtBU2FuIGlzIGFscmVhZHkgdXBzdHJlYW0uCj4+
Cj4+IFdlIGFyZSBhbHNvIG5vdCBhd2FyZSBvZiBhbnkgdXNlcnMgb2Yga21lbWNoZWNrIChvciB1
c2VycyB3aG8gZG9uJ3QgY29uc2lkZXIKPj4gS0FTYW4gYXMgYSBzdWl0YWJsZSByZXBsYWNlbWVu
dCkuCj4gCj4gRnJvbSBEb2N1bWVudGF0aW9uL2thc2FuLnR4dDoKPiAKPiAgICAgdGhlcmVmb3Jl
IHlvdSB3aWxsIG5lZWQgYSBjZXJ0YWluIHZlcnNpb24gb2YgR0NDID4gNC45LjIKPiAKPiBBRkFJ
SyBnY2MgNC45LjMgaGFzbid0IGJlZW4gcmVsZWFzZWQgeWV0LiAoT3IgZG9lcyBpdCBtZWFuID49
IDQuOS4yID8pCj4gCj4gQ2FuIHdlIHBlcmhhcHMgd2FpdCB1bnRpbCB0aGVyZSBpcyBhIHJlbGVh
c2VkIHZlcnNpb24gb2YgR0NDIHRoYXQgc3VwcG9ydHMKPiBLQVNhbj8gQW5kIG1heWJlIHRoZW4g
YSB0b3VjaCBsb25nZXIgc28gZm9sa3MgY2FuIHRlc3QgaXQgd29ya3Mgb24gdGhlaXIKPiBwbGF0
Zm9ybXM/CgpJIHRoaW5rIHRoaXMgaXMganVzdCBhbiBvZmYtYnktb25lIGluIHRoZSBkb2N1bWVu
dGF0aW9uLiBUaGUgY292ZXIgbGV0dGVyIGZvcgp0aGUgS0FTYW4gcGF0Y2hzZXQgc3RhdGVkOgoK
CUtBU0FOIHVzZXMgY29tcGlsZS10aW1lIGluc3RydW1lbnRhdGlvbiBmb3IgY2hlY2tpbmcgZXZl
cnkgbWVtb3J5IGFjY2VzcywgdGhlcmVmb3JlIHlvdQoJd2lsbCBuZWVkIGEgZnJlc2ggR0NDID49
IHY0LjkuMgoKClRoYW5rcywKU2FzaGEKCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fCkxpbnV4cHBjLWRldiBtYWlsaW5nIGxpc3QKTGludXhwcGMtZGV2QGxp
c3RzLm96bGFicy5vcmcKaHR0cHM6Ly9saXN0cy5vemxhYnMub3JnL2xpc3RpbmZvL2xpbnV4cHBj
LWRldg==

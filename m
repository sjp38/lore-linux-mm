From: Sasha Levin <sasha.levin@oracle.com>
Subject: Re: [PATCH] mm: kill kmemcheck
Date: Thu, 12 Mar 2015 08:51:08 -0400
Message-ID: <55018BBC.6010903@oracle.com>
References: <1426074547-21888-1-git-send-email-sasha.levin@oracle.com>
 <55013B38.6040100@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <55013B38.6040100@iki.fi>
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
To: Pekka Enberg <penberg@iki.fi>, linux-kernel@vger.kernel.org
Cc: Vladimir Davydov <vdavydov@parallels.com>, Geert Uytterhoeven <geert+renesas@glider.be>, SUPERH <linux-sh@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Mackerras <paulus@samba.org>, Pavel Machek <pavel@ucw.cz>, Miklos Szeredi <mszeredi@suse.cz>, Christoph Lameter <cl@linux.com>, Marek Szyprowski <m.szyprowski@samsung.com>, "open list:GENERIC INCLUDE/A..." <linux-arch@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Russell King <linux@arm.linux.org.uk>, Jingoo Han <jg1.han@samsung.com>, James Morris <jmorris@namei.org>, Chris Bainbridge <chris.bainbridge@gmail.com>, Antti Palosaari <crope@iki.fi>, Mel Gorman <mgorman@suse.de>, Ritesh Harjani <ritesh.harjani@gmail.com>, Shaohua Li <shli@kernel.org>, Alexander Duyck <alexander.h.duyck@intel.com>, Wang Nan <wangnan0@huawei.com>, Jiri
List-Id: linux-mm.kvack.org

T24gMDMvMTIvMjAxNSAwMzowNyBBTSwgUGVra2EgRW5iZXJnIHdyb3RlOgo+IEhpIFNhc2hhLAo+
IAo+IE9uIDMvMTEvMTUgMTo0MyBQTSwgU2FzaGEgTGV2aW4gd3JvdGU6Cj4+IEFzIGRpc2N1c3Nl
ZCBvbiBMU0YvTU0sIGtpbGwga21lbWNoZWNrLgo+Pgo+PiBLQVNhbiBpcyBhIHJlcGxhY2VtZW50
IHRoYXQgaXMgYWJsZSB0byB3b3JrIHdpdGhvdXQgdGhlIGxpbWl0YXRpb24gb2YKPj4ga21lbWNo
ZWNrIChzaW5nbGUgQ1BVLCBzbG93KS4gS0FTYW4gaXMgYWxyZWFkeSB1cHN0cmVhbS4KPj4KPj4g
V2UgYXJlIGFsc28gbm90IGF3YXJlIG9mIGFueSB1c2VycyBvZiBrbWVtY2hlY2sgKG9yIHVzZXJz
IHdobyBkb24ndCBjb25zaWRlcgo+PiBLQVNhbiBhcyBhIHN1aXRhYmxlIHJlcGxhY2VtZW50KS4K
Pj4KPj4gSSd2ZSBidWlsZCB0ZXN0ZWQgaXQgdXNpbmcgYWxsW3llcyxubyxtb2RdY29uZmlnIGFu
ZCBmdXp6ZWQgYSBiaXQgd2l0aCB0aGlzCj4+IHBhdGNoIGFwcGxpZWQsIGRpZG4ndCBub3RpY2Ug
YW55IGJhZCBiZWhhdmlvdXIuCj4+Cj4+IFNpZ25lZC1vZmYtYnk6IFNhc2hhIExldmluIDxzYXNo
YS5sZXZpbkBvcmFjbGUuY29tPgo+IAo+IENhbiB5b3UgZWxhYm9yYXRlIG9uIHdoYXQgZXhhY3Rs
eSB3YXMgZGlzY3Vzc2VkIGF0IExTRi9NTT8gUHJlZmVyYWJseSBpbiB0aGUgY29tbWl0IGxvZy4g
Oy0pCgpUaGVyZSB3YXNuJ3QgYSBsb25nIGRpc2N1c3Npb24gYWJvdXQgcmVtb3Zpbmcga21lbWNo
ZWNrLCBpdCBqdXN0IGZvbGxvd2VkIHVwCmEgS0FTYW4gdG9waWMgYW5kIHRoZSBxdWVzdGlvbiBv
ZiB3aGV0aGVyIGttZW1jaGVjayBjYW4gYmUgZGVwcmVjYXRlZCBub3cKdGhhdCBLQVNhbiBpcyBt
ZXJnZWQgY2FtZSB1cC4KCk5vIG9uZSBhdCB0aGUgcm9vbSBkaWRuJ3QgdXNlIGl0LCBrbmV3IGEg
dXNlciBvZiBpdCwgb3IgY291bGRuJ3QgZGVzY3JpYmUgYQp1c2VjYXNlIHdoZXJlIGttZW1jaGVj
ayB3YXMgc3VwZXJpb3IgdG8gS0FTYW4gLSBzbyB0aGUgY29uY2x1c2lvbiB3YXMgdG8gdHJ5CmFu
ZCByZXBsYWNlIGl0LgoKVGhlIG9ubHkgdGhpbmcgSSBjYW4gcmVhbGx5IHB1dCBpbiB0aGUgY2hh
bmdlbG9nIGlzIGEgcmVmZXJlbmNlIHRvIHRoZSBLQVNhbgpkb2NzIGFuZCB0byBhc2sgZm9sa3Mg
dG8gY29tcGxhaW4gbG91ZGx5IGlmIHdlIG1pc3NlZCBhIHVzZWNhc2UuCgoKVGhhbmtzLApTYXNo
YQpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpMaW51eHBw
Yy1kZXYgbWFpbGluZyBsaXN0CkxpbnV4cHBjLWRldkBsaXN0cy5vemxhYnMub3JnCmh0dHBzOi8v
bGlzdHMub3psYWJzLm9yZy9saXN0aW5mby9saW51eHBwYy1kZXY=

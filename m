From: Pekka Enberg <penberg@iki.fi>
Subject: Re: [PATCH] mm: kill kmemcheck
Date: Thu, 12 Mar 2015 09:07:36 +0200
Message-ID: <55013B38.6040100@iki.fi>
References: <1426074547-21888-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; Format="flowed"
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
To: Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org
Cc: Vladimir Davydov <vdavydov@parallels.com>, Geert Uytterhoeven <geert+renesas@glider.be>, SUPERH <linux-sh@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Mackerras <paulus@samba.org>, Pavel Machek <pavel@ucw.cz>, Miklos Szeredi <mszeredi@suse.cz>, Christoph Lameter <cl@linux.com>, Marek Szyprowski <m.szyprowski@samsung.com>, "open list:GENERIC INCLUDE/A..." <linux-arch@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Russell King <linux@arm.linux.org.uk>, Jingoo Han <jg1.han@samsung.com>, James Morris <jmorris@namei.org>, Chris Bainbridge <chris.bainbridge@gmail.com>, Antti Palosaari <crope@iki.fi>, Mel Gorman <mgorman@suse.de>, Ritesh Harjani <ritesh.harjani@gmail.com>, Shaohua Li <shli@kernel.org>, Alexander Duyck <alexander.h.duyck@intel.com>, Wang Nan <wangnan0@huawei.com>, Jiri
List-Id: linux-mm.kvack.org

SGkgU2FzaGEsCgpPbiAzLzExLzE1IDE6NDMgUE0sIFNhc2hhIExldmluIHdyb3RlOgo+IEFzIGRp
c2N1c3NlZCBvbiBMU0YvTU0sIGtpbGwga21lbWNoZWNrLgo+Cj4gS0FTYW4gaXMgYSByZXBsYWNl
bWVudCB0aGF0IGlzIGFibGUgdG8gd29yayB3aXRob3V0IHRoZSBsaW1pdGF0aW9uIG9mCj4ga21l
bWNoZWNrIChzaW5nbGUgQ1BVLCBzbG93KS4gS0FTYW4gaXMgYWxyZWFkeSB1cHN0cmVhbS4KPgo+
IFdlIGFyZSBhbHNvIG5vdCBhd2FyZSBvZiBhbnkgdXNlcnMgb2Yga21lbWNoZWNrIChvciB1c2Vy
cyB3aG8gZG9uJ3QgY29uc2lkZXIKPiBLQVNhbiBhcyBhIHN1aXRhYmxlIHJlcGxhY2VtZW50KS4K
Pgo+IEkndmUgYnVpbGQgdGVzdGVkIGl0IHVzaW5nIGFsbFt5ZXMsbm8sbW9kXWNvbmZpZyBhbmQg
ZnV6emVkIGEgYml0IHdpdGggdGhpcwo+IHBhdGNoIGFwcGxpZWQsIGRpZG4ndCBub3RpY2UgYW55
IGJhZCBiZWhhdmlvdXIuCj4KPiBTaWduZWQtb2ZmLWJ5OiBTYXNoYSBMZXZpbiA8c2FzaGEubGV2
aW5Ab3JhY2xlLmNvbT4KCkNhbiB5b3UgZWxhYm9yYXRlIG9uIHdoYXQgZXhhY3RseSB3YXMgZGlz
Y3Vzc2VkIGF0IExTRi9NTT8gUHJlZmVyYWJseSBpbiAKdGhlIGNvbW1pdCBsb2cuIDstKQoKLSBQ
ZWtrYQpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpMaW51
eHBwYy1kZXYgbWFpbGluZyBsaXN0CkxpbnV4cHBjLWRldkBsaXN0cy5vemxhYnMub3JnCmh0dHBz
Oi8vbGlzdHMub3psYWJzLm9yZy9saXN0aW5mby9saW51eHBwYy1kZXY=

From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] mm: kill kmemcheck
Date: Thu, 12 Mar 2015 11:27:57 +1030
Message-ID: <87egovxca2.fsf@rustcorp.com.au>
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
To: Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org
Cc: Vladimir Davydov <vdavydov@parallels.com>, Sam Ravnborg <sam@rav>, Geert Uytterhoeven <geert+renesas@glider.be>, "open list:SUPERH" <linux-sh@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Mackerras <paulus@samba.org>, Pavel Machek <pavel@ucw.cz>, Miklos Szeredi <mszeredi@suse.cz>, Christoph Lameter <cl@linux.com>, Marek Szyprowski <m.szyprowski@samsung.com>, "open list:GENERIC INCLUDE/A..." <linux-arch@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Russell King <linux@arm.linux.org.uk>, Kukjin Kim <kgene@kernel.org>, Jingoo Han <jg1.han@samsung.com>, James Morris <jmorris@namei.org>, Chris Bainbridge <chris.bainbridge@gmail.com>, Antti Palosaari <crope@iki.fi>, Mel Gorman <mgorman@suse.de>, Ritesh Harjani <ritesh.harjani@gmail.com>, Shaohua Li <shli@kernel.org>, Alexander
List-Id: linux-mm.kvack.org

U2FzaGEgTGV2aW4gPHNhc2hhLmxldmluQG9yYWNsZS5jb20+IHdyaXRlczoKPiBBcyBkaXNjdXNz
ZWQgb24gTFNGL01NLCBraWxsIGttZW1jaGVjay4KCkRhbW46IEkgbGl0ZXJhbGx5IGFkZGVkIENP
TkZJR19LTUVNQ0hFQ0sgc3VwcG9ydCB0byB2aXJ0aW8geWVzdGVyZGF5IQoKV2lsbCB0cnkgS2Fz
YW4gbm93LgoKVGhhbmtzIGZvciB0aGUgaGVhZHMtdXAsClJ1c3R5LgpfX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpMaW51eHBwYy1kZXYgbWFpbGluZyBsaXN0
CkxpbnV4cHBjLWRldkBsaXN0cy5vemxhYnMub3JnCmh0dHBzOi8vbGlzdHMub3psYWJzLm9yZy9s
aXN0aW5mby9saW51eHBwYy1kZXY=

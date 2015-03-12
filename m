From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH] mm: kill kmemcheck
Date: Thu, 12 Mar 2015 09:00:15 -0400
Message-ID: <20150312090015.656c2f9c@lwn.net>
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
To: Pekka Enberg <penberg@iki.fi>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Geert Uytterhoeven <geert+renesas@glider.be>, "open list:SUPERH" <linux-sh@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Mackerras <paulus@samba.org>, Pavel Machek <pavel@ucw.cz>, Miklos Szeredi <mszeredi@suse.cz>, Christoph Lameter <cl@linux.com>, Marek Szyprowski <m.szyprowski@samsung.com>, "open list:GENERIC INCLUDE/A..." <linux-arch@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Russell King <linux@arm.linux.org.uk>, Jingoo Han <jg1.han@samsung.com>, James Morris <jmorris@namei.org>, Chris Bainbridge <chris.bainbridge@gmail.com>, Antti Palosaari <crope@iki.fi>, Mel Gorman <mgorman@suse.de>, Ritesh Harjani <ritesh.harjani@gmail.com>, Shaohua Li <shli@kernel.org>, Alexander Duyck <alexander.h.duyck@intel.com>, Wang Nan <wangnan0@huawei>
List-Id: linux-mm.kvack.org

T24gVGh1LCAxMiBNYXIgMjAxNSAwOTowNzozNiArMDIwMApQZWtrYSBFbmJlcmcgPHBlbmJlcmdA
aWtpLmZpPiB3cm90ZToKCj4gQ2FuIHlvdSBlbGFib3JhdGUgb24gd2hhdCBleGFjdGx5IHdhcyBk
aXNjdXNzZWQgYXQgTFNGL01NPyBQcmVmZXJhYmx5IGluIAo+IHRoZSBjb21taXQgbG9nLiA7LSkK
CkknbGwgaGF2ZSB0aGUgcmVwb3J0IGZyb20gdGhhdCBzZXNzaW9uIHVwLCBob3BlZnVsbHkgYnkg
dGhlIGVuZCBvZiB0aGUKd2Vlay4KClRoYW5rcywKCmpvbgpfX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fXwpMaW51eHBwYy1kZXYgbWFpbGluZyBsaXN0CkxpbnV4
cHBjLWRldkBsaXN0cy5vemxhYnMub3JnCmh0dHBzOi8vbGlzdHMub3psYWJzLm9yZy9saXN0aW5m
by9saW51eHBwYy1kZXY=

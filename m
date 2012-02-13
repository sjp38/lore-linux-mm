Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 2C7EE6B13F0
	for <linux-mm@kvack.org>; Mon, 13 Feb 2012 11:22:47 -0500 (EST)
Received: by yenl5 with SMTP id l5so3015248yen.14
        for <linux-mm@kvack.org>; Mon, 13 Feb 2012 08:22:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1329006098-5454-4-git-send-email-andrea@betterlinux.com>
References: <1329006098-5454-1-git-send-email-andrea@betterlinux.com> <1329006098-5454-4-git-send-email-andrea@betterlinux.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Mon, 13 Feb 2012 11:22:26 -0500
Message-ID: <CAHGf_=qs8-nE6y6EzNYUzgjGo0sMP5zvCc3=GNZmHct6mPecqg@mail.gmail.com>
Subject: Re: [PATCH v5 3/3] fadvise: implement POSIX_FADV_NOREUSE
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <andrea@betterlinux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Shaohua Li <shaohua.li@intel.com>, =?ISO-8859-1?Q?P=E1draig_Brady?= <P@draigbrady.com>, John Stultz <john.stultz@linaro.org>, Jerry James <jamesjer@betterlinux.com>, Julius Plenz <julius@plenz.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

PiBAQCAtMTE4MSw4ICsxMjU4LDIyIEBAIHBhZ2Vfb2s6Cj4goCCgIKAgoCCgIKAgoCCgICogV2hl
biBhIHNlcXVlbnRpYWwgcmVhZCBhY2Nlc3NlcyBhIHBhZ2Ugc2V2ZXJhbCB0aW1lcywKPiCgIKAg
oCCgIKAgoCCgIKAgKiBvbmx5IG1hcmsgaXQgYXMgYWNjZXNzZWQgdGhlIGZpcnN0IHRpbWUuCj4g
oCCgIKAgoCCgIKAgoCCgICovCj4gLSCgIKAgoCCgIKAgoCCgIGlmIChwcmV2X2luZGV4ICE9IGlu
ZGV4IHx8IG9mZnNldCAhPSBwcmV2X29mZnNldCkKPiAtIKAgoCCgIKAgoCCgIKAgoCCgIKAgoCBt
YXJrX3BhZ2VfYWNjZXNzZWQocGFnZSk7Cj4gKyCgIKAgoCCgIKAgoCCgIGlmIChwcmV2X2luZGV4
ICE9IGluZGV4IHx8IG9mZnNldCAhPSBwcmV2X29mZnNldCkgewo+ICsgoCCgIKAgoCCgIKAgoCCg
IKAgoCCgIGludCBtb2RlOwo+ICsKPiArIKAgoCCgIKAgoCCgIKAgoCCgIKAgoCBtb2RlID0gZmls
ZW1hcF9nZXRfY2FjaGUobWFwcGluZywgaW5kZXgpOwo+ICsgoCCgIKAgoCCgIKAgoCCgIKAgoCCg
IHN3aXRjaCAobW9kZSkgewo+ICsgoCCgIKAgoCCgIKAgoCCgIKAgoCCgIGNhc2UgRklMRU1BUF9D
QUNIRV9OT1JNQUw6Cj4gKyCgIKAgoCCgIKAgoCCgIKAgoCCgIKAgoCCgIKAgoCBtYXJrX3BhZ2Vf
YWNjZXNzZWQocGFnZSk7Cj4gKyCgIKAgoCCgIKAgoCCgIKAgoCCgIKAgoCCgIKAgoCBicmVhazsK
PiArIKAgoCCgIKAgoCCgIKAgoCCgIKAgoCBjYXNlIEZJTEVNQVBfQ0FDSEVfT05DRToKPiArIKAg
oCCgIKAgoCCgIKAgoCCgIKAgoCCgIKAgoCCgIG1hcmtfcGFnZV91c2Vkb25jZShwYWdlKTsKPiAr
IKAgoCCgIKAgoCCgIKAgoCCgIKAgoCCgIKAgoCCgIGJyZWFrOwo+ICsgoCCgIKAgoCCgIKAgoCCg
IKAgoCCgIGRlZmF1bHQ6Cj4gKyCgIKAgoCCgIKAgoCCgIKAgoCCgIKAgoCCgIKAgoCBXQVJOX09O
X09OQ0UoMSk7Cj4gKyCgIKAgoCCgIKAgoCCgIKAgoCCgIKAgoCCgIKAgoCBicmVhazsKCkhlcmUg
aXMgZ2VuZXJpY19maWxlX3JlYWQsIHJpZ2h0PyBXaHkgZG9uJ3QgeW91IGNhcmUgd3JpdGUgYW5k
IHBhZ2UgZmF1bHQ/Cg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

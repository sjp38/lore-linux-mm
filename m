Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 329EC6B0033
	for <linux-mm@kvack.org>; Sun, 22 Jan 2017 23:44:10 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id m98so142018555iod.2
        for <linux-mm@kvack.org>; Sun, 22 Jan 2017 20:44:10 -0800 (PST)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id e9si7826162ita.102.2017.01.22.20.44.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Jan 2017 20:44:09 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC] HWPOISON: soft offlining for non-lru movable page
Date: Mon, 23 Jan 2017 04:26:40 +0000
Message-ID: <20170123042639.GA5610@hori1.linux.bs1.fc.nec.co.jp>
References: <1484712054-7997-1-git-send-email-xieyisheng1@huawei.com>
 <20170118094530.GA29579@hori1.linux.bs1.fc.nec.co.jp>
 <ccf71cb7-3a12-0bf4-ad79-b235f6df94c6@huawei.com>
In-Reply-To: <ccf71cb7-3a12-0bf4-ad79-b235f6df94c6@huawei.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <D5096D1F93D3E7479A2F9FB37AA32B77@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mhocko@suse.com" <mhocko@suse.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan@kernel.org" <minchan@kernel.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "qiuxishi@huawei.com" <qiuxishi@huawei.com>

On Fri, Jan 20, 2017 at 05:52:13PM +0800, Yisheng Xie wrote:
> Hi Naoya,
>=20
> On 2017/1/18 17:45, Naoya Horiguchi wrote:
> > On Wed, Jan 18, 2017 at 12:00:54PM +0800, Yisheng Xie wrote:
> >> This patch is to extends soft offlining framework to support
> >> non-lru page, which already support migration after
> >> commit bda807d44454 ("mm: migrate: support non-lru movable page
> >> migration")
> >>
> >> When memory corrected errors occur on a non-lru movable page,
> >> we can choose to stop using it by migrating data onto another
> >> page and disable the original (maybe half-broken) one.
> >>
> >> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> >=20
> > It looks OK in my quick glance. I'll do some testing more tomorrow.
> >=20
> Thanks for reviewing.
> I have do some basic test like offline movable page and unpoison it.
> Do you have some test suit or test suggestion? So I can do some more
> test of it for double check? Very thanks for that.

I've tried soft offline on zram pages with your v2 patch, and it works fine=
.
I have no specific suggestion about other testcases.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

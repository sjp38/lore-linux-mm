Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id A18906B0031
	for <linux-mm@kvack.org>; Sat, 18 Jan 2014 05:45:41 -0500 (EST)
Received: by mail-we0-f175.google.com with SMTP id p61so5360649wes.6
        for <linux-mm@kvack.org>; Sat, 18 Jan 2014 02:45:40 -0800 (PST)
Received: from mail-we0-x22d.google.com (mail-we0-x22d.google.com [2a00:1450:400c:c03::22d])
        by mx.google.com with ESMTPS id ez4si10521005wjd.25.2014.01.18.02.45.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 18 Jan 2014 02:45:40 -0800 (PST)
Received: by mail-we0-f173.google.com with SMTP id t60so5383195wes.4
        for <linux-mm@kvack.org>; Sat, 18 Jan 2014 02:45:40 -0800 (PST)
Subject: Re: [PATCH] mm/kmemleak: add support for re-enable kmemleak at runtime
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Content-Type: text/plain; charset=us-ascii
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <52DA3E41.9050202@huawei.com>
Date: Sat, 18 Jan 2014 10:45:38 +0000
Content-Transfer-Encoding: quoted-printable
Message-Id: <CE7DF1D3-12AE-4A97-BF05-84FF223C8520@arm.com>
References: <52D8FA72.8080100@huawei.com> <20140117120436.GC28895@arm.com> <52DA3E41.9050202@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "rob@landley.net" <rob@landley.net>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Li Zefan <lizefan@huawei.com>, Wang Nan <wangnan0@huawei.com>

On 18 Jan 2014, at 08:41, Jianguo Wu <wujianguo@huawei.com> wrote:
> On 2014/1/17 20:04, Catalin Marinas wrote:
>> On Fri, Jan 17, 2014 at 09:40:02AM +0000, Jianguo Wu wrote:
>>> Now disabling kmemleak is an irreversible operation, but sometimes
>>> we may need to re-enable kmemleak at runtime. So add a knob to =
enable
>>> kmemleak at runtime:
>>> echo on > /sys/kernel/debug/kmemleak
>>=20
>> It is irreversible for very good reason: once it missed the initial
>> memory allocations, there is no way for kmemleak to build the object
>> reference graph and you'll get lots of false positives, pretty much
>> making it unusable.
>=20
> Do you mean we didn't trace memory allocations during kmemleak disable =
period,
> and these memory may reference to new allocated objects after =
re-enable?=20

Yes. Those newly allocated objects would be reported as leaks.

Catalin=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

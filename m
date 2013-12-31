Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id 0BF6B6B0031
	for <linux-mm@kvack.org>; Tue, 31 Dec 2013 05:12:06 -0500 (EST)
Received: by mail-qc0-f175.google.com with SMTP id e9so11673397qcy.20
        for <linux-mm@kvack.org>; Tue, 31 Dec 2013 02:12:05 -0800 (PST)
Received: from mail-ob0-x232.google.com (mail-ob0-x232.google.com [2607:f8b0:4003:c01::232])
        by mx.google.com with ESMTPS id h18si45710819qen.46.2013.12.31.02.12.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 31 Dec 2013 02:12:05 -0800 (PST)
Received: by mail-ob0-f178.google.com with SMTP id uz6so12668893obc.9
        for <linux-mm@kvack.org>; Tue, 31 Dec 2013 02:12:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52C2811C.4090907@huawei.com>
References: <52C2811C.4090907@huawei.com>
Date: Tue, 31 Dec 2013 11:12:04 +0100
Message-ID: <CAOMGZ=GOR_i9ixvHeHwfDN1wwwSQzFNFGa4qLZMhWWNzx0p8mw@mail.gmail.com>
Subject: Re: [PATCH] mm: add a new command-line kmemcheck value
From: Vegard Nossum <vegard.nossum@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Vegard Nossum <vegardno@ifi.uio.no>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, wangnan0@huawei.com, the arch/x86 maintainers <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

(Oops, resend to restore Cc.)

Hi,

On 31 December 2013 09:32, Xishi Qiu <qiuxishi@huawei.com> wrote:
> Add a new command-line kmemcheck value: kmemcheck=3 (disable the feature),
> this is the same effect as CONFIG_KMEMCHECK disabled.
> After doing this, we can enable/disable kmemcheck feature in one vmlinux.

Could you please explain what exactly the difference is between the
existing kmemcheck=0 parameter and the new kmemcheck=3?

Thanks,


Vegard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

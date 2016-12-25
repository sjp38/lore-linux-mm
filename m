Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1FCD46B0038
	for <linux-mm@kvack.org>; Sat, 24 Dec 2016 21:22:38 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id d22so61752223qtd.3
        for <linux-mm@kvack.org>; Sat, 24 Dec 2016 18:22:38 -0800 (PST)
Received: from mail1.bemta8.messagelabs.com (mail1.bemta8.messagelabs.com. [216.82.243.194])
        by mx.google.com with ESMTPS id p52si23090804qta.125.2016.12.24.18.22.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Dec 2016 18:22:37 -0800 (PST)
From: Dashi DS1 Cao <caods1@lenovo.com>
Subject: RE: A small window for a race condition in
 mm/rmap.c:page_lock_anon_vma_read
Date: Sun, 25 Dec 2016 02:22:31 +0000
Message-ID: <23B7B563BA4E9446B962B142C86EF24ADBFD2D@CNMAILEX03.lenovo.com>
References: <23B7B563BA4E9446B962B142C86EF24ADBD62C@CNMAILEX03.lenovo.com>
 <20161221144343.GD593@dhcp22.suse.cz>
 <20161222135106.GY3124@twins.programming.kicks-ass.net>
 <alpine.LSU.2.11.1612221351340.1744@eggly.anvils>
 <23B7B563BA4E9446B962B142C86EF24ADBF309@CNMAILEX03.lenovo.com>
 <20161223141957.GT3107@twins.programming.kicks-ass.net>
In-Reply-To: <20161223141957.GT3107@twins.programming.kicks-ass.net>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

It's a CentOS 7.2, so there is point in asking RHT. I'll try to persuade th=
e customer to have a try with kernel version 4.9, if only I can get it work=
 with CentOS 7.2.

Dashi Cao

-----Original Message-----
From: Peter Zijlstra [mailto:peterz@infradead.org]=20
Sent: Friday, December 23, 2016 10:20 PM
To: Dashi DS1 Cao <caods1@lenovo.com>
Cc: Hugh Dickins <hughd@google.com>; Michal Hocko <mhocko@kernel.org>; linu=
x-mm@kvack.org; linux-kernel@vger.kernel.org
Subject: Re: A small window for a race condition in mm/rmap.c:page_lock_ano=
n_vma_read

On Fri, Dec 23, 2016 at 02:02:14AM +0000, Dashi DS1 Cao wrote:
> The kernel version is "RELEASE: 3.10.0-327.36.3.el7.x86_64". It was the l=
atest kernel release of CentOS 7.2 at that time, or maybe still now.

This would be the point where we ask you to run a recent upstream kernel an=
d try and reproduce the problem with that, or contact RHT for support on th=
eir franken-kernel ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

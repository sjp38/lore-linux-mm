Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0EDF88E00F9
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 20:28:06 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 75so38224568pfq.8
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 17:28:06 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 64si54874719ply.372.2019.01.04.17.28.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 17:28:04 -0800 (PST)
Date: Fri, 4 Jan 2019 17:28:02 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: KMSAN: uninit-value in mpol_rebind_mm
Message-Id: <20190104172802.ce9c4b77577a9c2810f04171@linux-foundation.org>
In-Reply-To: <52835ef5-6351-3852-d4ba-b6de285f96f5@suse.cz>
References: <000000000000c06550057e4cac7c@google.com>
	<a71997c3-e8ae-a787-d5ce-3db05768b27c@suse.cz>
	<CACT4Y+bRvwxkdnyRosOujpf5-hkBwd2g0knyCQHob7p=0hC=Dw@mail.gmail.com>
	<52835ef5-6351-3852-d4ba-b6de285f96f5@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Dmitry Vyukov <dvyukov@google.com>, syzbot <syzbot+b19c2dc2c990ea657a71@syzkaller.appspotmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexander Potapenko <glider@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux@dominikbrodowski.net, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, xieyisheng1@huawei.com, zhong jiang <zhongjiang@huawei.com>

On Fri, 4 Jan 2019 09:50:31 +0100 Vlastimil Babka <vbabka@suse.cz> wrote:

> > Yes, it doesn't and it's not trivial to do. The tool reports uses of
> > unint _values_. Values don't necessary reside in memory. It can be a
> > register, that come from another register that was calculated as a sum
> > of two other values, which may come from a function argument, etc.
> 
> I see. BTW, the patch I sent will be picked up for testing, or does it
> have to be in mmotm/linux-next first?

I grabbed it.  To go further we'd need a changelog, a signoff,
description of testing status, reviews, a Fixes: and perhaps a
cc:stable ;)

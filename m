Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 22EBD6B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 10:47:50 -0500 (EST)
Received: by mail-qg0-f53.google.com with SMTP id o11so41921512qge.2
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 07:47:50 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w132si10192215qka.53.2016.01.28.07.47.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 07:47:49 -0800 (PST)
Date: Thu, 28 Jan 2016 16:47:46 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: mm: BUG in expand_downwards
Message-ID: <20160128154746.GI12228@redhat.com>
References: <CACT4Y+Y908EjM2z=706dv4rV6dWtxTLK9nFg9_7DhRMLppBo2g@mail.gmail.com>
 <CALYGNiP6-T=LuBwzKys7TPpFAiGC-U7FymDT4kr3Zrcfo7CoiQ@mail.gmail.com>
 <CACT4Y+YNUZumEy2-OXhDku3rdn-4u28kCDRKtgYaO2uA9cYv5w@mail.gmail.com>
 <CACT4Y+afp8BaUvQ72h7RzQuMOX05iDEyP3p3wuZfjaKcW_Ud9A@mail.gmail.com>
 <20160127194132.GA896@redhat.com>
 <CACT4Y+Z86=NoNPrS-vgtJiB54Akwq6FfAPf2wnBA1FX2BHafWQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+Z86=NoNPrS-vgtJiB54Akwq6FfAPf2wnBA1FX2BHafWQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Michal Hocko <mhocko@suse.com>, Piotr Kwapulinski <kwapulinski.piotr@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>

Hello,

On Wed, Jan 27, 2016 at 10:11:44PM +0100, Dmitry Vyukov wrote:
> Sorry, I meant only the second once. The mm bug.
> I guess you need at least CONFIG_DEBUG_VM.  Run it in a tight parallel
> loop with CPU oversubscription (e.g. 32 parallel processes on 2 cores)
> for  at least an hour.

Does this help for the mm bug?

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id E9E6C8E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 14:46:53 -0500 (EST)
Received: by mail-lf1-f71.google.com with SMTP id z10so3782617lfe.21
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 11:46:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x82sor15219027lff.40.2019.01.05.11.46.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 05 Jan 2019 11:46:52 -0800 (PST)
Received: from mail-lf1-f44.google.com (mail-lf1-f44.google.com. [209.85.167.44])
        by smtp.gmail.com with ESMTPSA id y23-v6sm13011951ljk.95.2019.01.05.11.46.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 11:46:50 -0800 (PST)
Received: by mail-lf1-f44.google.com with SMTP id y14so8630522lfg.13
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 11:46:49 -0800 (PST)
MIME-Version: 1.0
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
In-Reply-To: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 5 Jan 2019 11:46:33 -0800
Message-ID: <CAHk-=wicks2BEwm1BhdvEj_P3yawmvQuG3NOnjhdrUDEtTGizw@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org

On Sat, Jan 5, 2019 at 9:27 AM Jiri Kosina <jikos@kernel.org> wrote:
>
> From: Jiri Kosina <jkosina@suse.cz>
>
> There are possibilities [1] how mincore() could be used as a converyor of
> a sidechannel information about pagecache metadata.

Can we please just limit it to vma's that are either anonymous, or map
a file that the user actually owns?

Then the capability check could be for "override the file owner check"
instead, which makes tons of sense.

No new sysctl's for something like this, please.

             Linus

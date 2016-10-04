Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id A17546B0038
	for <linux-mm@kvack.org>; Tue,  4 Oct 2016 14:54:00 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id t193so8131486ywc.2
        for <linux-mm@kvack.org>; Tue, 04 Oct 2016 11:54:00 -0700 (PDT)
Received: from mail-yw0-x233.google.com (mail-yw0-x233.google.com. [2607:f8b0:4002:c05::233])
        by mx.google.com with ESMTPS id w198si2742577ywd.275.2016.10.04.11.45.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Oct 2016 11:45:52 -0700 (PDT)
Received: by mail-yw0-x233.google.com with SMTP id g192so139482679ywh.1
        for <linux-mm@kvack.org>; Tue, 04 Oct 2016 11:45:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2b7d6bd6-7d16-3c60-1b84-a172ba378402@gmx.de>
References: <fcb653b9-cd9e-5cec-1036-4b4c9e1d3e7b@gmx.de> <20161004084136.GD17515@quack2.suse.cz>
 <90dfe18f-9fe7-819d-c410-cdd160644ab7@gmx.de> <2b7d6bd6-7d16-3c60-1b84-a172ba378402@gmx.de>
From: Andrey Korolyov <andrey@xdel.ru>
Date: Tue, 4 Oct 2016 21:45:32 +0300
Message-ID: <CABYiri-UUT6zVGyNENp-aBJDj6Oikodc5ZA27Gzq5-bVDqjZ4g@mail.gmail.com>
Subject: Re: Frequent ext4 oopses with 4.4.0 on Intel NUC6i3SYB
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Bauer <dfnsonfsduifb@gmx.de>
Cc: Jan Kara <jack@suse.cz>, linux-ext4@vger.kernel.org, linux-mm@kvack.org

On Tue, Oct 4, 2016 at 8:32 PM, Johannes Bauer <dfnsonfsduifb@gmx.de> wrote:
> On 04.10.2016 18:50, Johannes Bauer wrote:
>
>> Uhh, that sounds painful. So I'm following Ted's advice and building
>> myself a 4.8 as we speak.
>
> Damn bad idea to build on the instable target. Lots of gcc segfaults and
> weird stuff, even without a kernel panic. The system appears to be
> instable as hell. Wonder how it can even run and how much of the root fs
> is already corrupted :-(
>
> Rebuilding 4.8 on a different host.

Looks like a platform itself is somewhat faulty: [1]. Also please bear
in mind that standalone memory testers would rather not expose certain
classes of memory failures, I`d suggest to test allocator`s work
against gcc runs on tmpfs, almost same as you did before. Frequency of
crashes due to wrong pointer contents of an fs cache is most probably
a direct outcome from its relative memory footprint.

1. https://communities.intel.com/thread/105640

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

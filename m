Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B769B6B0010
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 08:42:14 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id v12-v6so4366494wmc.1
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 05:42:14 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 35-v6si285128edh.126.2018.06.04.05.42.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Jun 2018 05:42:13 -0700 (PDT)
Date: Mon, 4 Jun 2018 14:42:10 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] kmemleak: don't use __GFP_NOFAIL
Message-ID: <20180604124210.GQ19202@dhcp22.suse.cz>
References: <f054219d-6daa-68b1-0c60-0acd9ad8c5ab@i-love.sakura.ne.jp>
 <1730157334.5467848.1527672937617.JavaMail.zimbra@redhat.com>
 <20180530104637.GC27180@dhcp22.suse.cz>
 <1684479370.5483281.1527680579781.JavaMail.zimbra@redhat.com>
 <20180530123826.GF27180@dhcp22.suse.cz>
 <20180531152225.2ck6ach4lma4zeim@armageddon.cambridge.arm.com>
 <20180531184104.GT15278@dhcp22.suse.cz>
 <1390612460.6539623.1527817820286.JavaMail.zimbra@redhat.com>
 <57176788.6562837.1527828823442.JavaMail.zimbra@redhat.com>
 <CACT4Y+ZE_qbnqzjnhbrk=vhLqijKZ5x1QbtbJSyNuqA3htFgFA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+ZE_qbnqzjnhbrk=vhLqijKZ5x1QbtbJSyNuqA3htFgFA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Chunyu Hu <chuhu@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, malat@debian.org, Linux-MM <linux-mm@kvack.org>, Akinobu Mita <akinobu.mita@gmail.com>

On Mon 04-06-18 10:41:39, Dmitry Vyukov wrote:
[...]
> FWIW this problem is traditionally solved in dynamic analysis tools by
> embedding meta info right in headers of heap blocks. All of KASAN,
> KMSAN, slub debug, LeakSanitizer, asan, valgrind work this way. Then
> an object is either allocated or not. If caller has something to
> prevent allocations from failing in any context, then the same will be
> true for KMEMLEAK meta data.
> 

This makes much more sense, of course. I thought there were some
fundamental reasons why kmemleak needs to have an off-object tracking
which makes the whole thing much more complicated of course.

-- 
Michal Hocko
SUSE Labs

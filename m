Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C10DCC4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 03:16:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89621218A1
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 03:16:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89621218A1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 095236B0269; Thu, 14 Mar 2019 23:16:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 043606B026A; Thu, 14 Mar 2019 23:16:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E75486B026B; Thu, 14 Mar 2019 23:16:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A33026B0269
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 23:16:49 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id z26so2961250pfa.7
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 20:16:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=IUB+yUuwUkJce0Q3R1yjfPaL3wwssMR6Fd5G5nd/6jQ=;
        b=aAR7RpnhE3WZ4xHwXAtJxhcP80EVplSr+CK0CiqBbxMBxU10AKzSJVU+JnjCubsI59
         nwv/tfUOu7hsKqTMCFo0VK0AW7D7kssdOLJ4Rx2b0/h9fPM9epJumumg88Hx2qyosiiP
         vEuQFh1JgLT5cPKRr4hoqFZU0F8oNvNkpK/iYpJ5frDlVhCf3HSM2H6c2DWJV4WQL6Qt
         Z6v8hZUPc7vFsRHRpAtucC/5WXHaWhE4cXA+EBMDKaviLnKLDingcthy2+zRLqb8NxSR
         AzTlv2eVtqD4mVbeLGLz152fSND1JPRnnzuShk7EugFuu7556ijO0M2Dw9UI9EDGS7gC
         k97A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of srs0=vfcv=rs=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=VfCv=RS=goodmis.org=rostedt@kernel.org"
X-Gm-Message-State: APjAAAXkGplv+3mUnUwgkakhqKaFUbTPPgUvRWyz+BUPCAADaNDrqFjt
	QWow4zNqcl0Zq1PAbB9hT4C2SVaMpVIADKnfqDiOJv54W+xFr2c3jyXka+GzbkdSGBLAmxamnlf
	mSF64N1V5CpusHaE086Z7eAoXbSXlQDlRM39x3zP6zXJPLA3ACa50e9lDzX/1h2A=
X-Received: by 2002:a63:cc01:: with SMTP id x1mr1184489pgf.221.1552619809194;
        Thu, 14 Mar 2019 20:16:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzy3V/h+dOfXqFKjOtQp4xryqX5vw8yeExBqr50fZ8DDRTN7oX7U/D+T9G/spsUZMdn/Avc
X-Received: by 2002:a63:cc01:: with SMTP id x1mr1184430pgf.221.1552619808106;
        Thu, 14 Mar 2019 20:16:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552619808; cv=none;
        d=google.com; s=arc-20160816;
        b=YloZYACq6JbbjZE/TbkVKTrJuSxu+Hsr+TXiUsJPyBQdpwFWfypVrMXVQWjxiHmeQO
         F/0KWfh+oG1ETFUokU/KtsxmeaD6UtPpVD5wlx3jl49Ng4nJeOr3LiH4DsOkUAe5GNol
         l5Reuxewj1LRuEFETBnbi9gejjWHXgC9sDjrrfw6vngflKC8scqfo4LiJO4aNLX9tF0f
         HRJ8iFlNjdLrYagFqTYXSXxnyLsyH8GPgWVThBCHXzpF1zX//f1YlFp/kBcHqh1fwNNq
         G0jj2iLQmzi1xmqVFFdxgdQuMurBS+Vqm5NZEb4rcJz5Mxj7k49qPHQGFyPUMKb13yBz
         fH2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=IUB+yUuwUkJce0Q3R1yjfPaL3wwssMR6Fd5G5nd/6jQ=;
        b=kRlhMseT6GZTJ5bx+KRKMRFxBVnTWqPxGtL0/aM3s70wxRQ+FQE8IiNpdoDzfmFMJz
         KGIIllT7hxY1nvYTqfJ8VWfFmnE9vXxRKnUTJ/O/500de3Abk17IvZL3kxiGd/MSOBMb
         oPUuoybKcgwTNNsckKH7+tLU9hqwfxK6B+7/q2IBfLQkD65ATaZ1bnSH7dxlswxYg+mh
         8LWikQ+cjHylMOiUaqJu5EIRGqHWVx5DjLUpGuxLgTrlu0I/W+2usB97b2LznX9hhGbT
         stZkiwo5JULpGfb/lexpjuEMOvJe7Amu58vQqNrujQODzvmCbc9oAMiKyeJtB9hKs8pZ
         jN1w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of srs0=vfcv=rs=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=VfCv=RS=goodmis.org=rostedt@kernel.org"
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b1si768347pgq.72.2019.03.14.20.16.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 20:16:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of srs0=vfcv=rs=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of srs0=vfcv=rs=goodmis.org=rostedt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom="SRS0=VfCv=RS=goodmis.org=rostedt@kernel.org"
Received: from oasis.local.home (cpe-66-24-58-225.stny.res.rr.com [66.24.58.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id F404321873;
	Fri, 15 Mar 2019 03:16:45 +0000 (UTC)
Date: Thu, 14 Mar 2019 23:16:41 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Sultan Alsawaf <sultan@kerneltoast.com>
Cc: Joel Fernandes <joel@joelfernandes.org>, Tim Murray
 <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>, Suren
 Baghdasaryan <surenb@google.com>, Greg Kroah-Hartman
 <gregkh@linuxfoundation.org>, Arve =?UTF-8?B?SGrDuG5uZXbDpWc=?=
 <arve@android.com>, Todd Kjos <tkjos@android.com>, Martijn Coenen
 <maco@android.com>, Christian Brauner <christian@brauner.io>, Ingo Molnar
 <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, LKML
 <linux-kernel@vger.kernel.org>, "open list:ANDROID DRIVERS"
 <devel@driverdev.osuosl.org>, linux-mm <linux-mm@kvack.org>, kernel-team
 <kernel-team@android.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for
 Android
Message-ID: <20190314231641.5a37932b@oasis.local.home>
In-Reply-To: <20190314204911.GA875@sultan-box.localdomain>
References: <20190310203403.27915-1-sultan@kerneltoast.com>
	<20190311174320.GC5721@dhcp22.suse.cz>
	<20190311175800.GA5522@sultan-box.localdomain>
	<CAJuCfpHTjXejo+u--3MLZZj7kWQVbptyya4yp1GLE3hB=BBX7w@mail.gmail.com>
	<20190311204626.GA3119@sultan-box.localdomain>
	<CAJuCfpGpBxofTT-ANEEY+dFCSdwkQswox3s8Uk9Eq0BnK9i0iA@mail.gmail.com>
	<20190312080532.GE5721@dhcp22.suse.cz>
	<20190312163741.GA2762@sultan-box.localdomain>
	<CAEe=Sxn_uayj48wo7oqf8mNZ7QAGJUQVmkPcHcuEGjA_Z8ELeQ@mail.gmail.com>
	<CAEXW_YQMnbN+e-janGbZc5MH6MwdUdXNfonpLUu5O2nsSkJyeg@mail.gmail.com>
	<20190314204911.GA875@sultan-box.localdomain>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Mar 2019 13:49:11 -0700
Sultan Alsawaf <sultan@kerneltoast.com> wrote:

> Perhaps I'm missing something, but if you want to know when a process has died
> after sending a SIGKILL to it, then why not just make the SIGKILL optionally
> block until the process has died completely? It'd be rather trivial to just
> store a pointer to an onstack completion inside the victim process' task_struct,
> and then complete it in free_task().

How would you implement such a method in userspace? kill() doesn't take
any parameters but the pid of the process you want to send a signal to,
and the signal to send. This would require a new system call, and be
quite a bit of work. If you can solve this with an ebpf program, I
strongly suggest you do that instead.

-- Steve


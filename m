Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E450FC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 20:49:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 999D420651
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 20:49:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 999D420651
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kerneltoast.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 450FE6B0003; Thu, 14 Mar 2019 16:49:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D8606B0005; Thu, 14 Mar 2019 16:49:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A17D6B0006; Thu, 14 Mar 2019 16:49:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id E1DE26B0003
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 16:49:18 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id 66so2966243otl.23
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 13:49:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Wt8gOJHFNkRgmDnlN6CzGFr6EJDxliPV9hJpCDt7EGo=;
        b=tHPUM5Jd7pM4wFNmhbnYtelEVtDPvon7nIof1aB2CR3Nq+jjN6yedVWtgXuSKRUIHs
         AQjtNQYp0DlZgk8iYwRkq+bnQy4I2LTv/BA9jGk7KMjZajjTtIc1jXFlOLatdofZozws
         H5EBsbSk5QHGz1ofkJ0WM8jBRjbf/gW7mgBX3/g00PAw6WSil9GQepHjSOjpAtGJLFHp
         nJxNFHawroHgbBfueA+NZ6Wy28ELrC0G4Qyc7+45uCx17YAEkk0NXvTWby6dJLIeWcpz
         CqJu1LLv+lsrXhc878kCdYumRBltTx52Csf/OwHzSh0LkLpxiF5UA/ZJ0BdcOwo1XADD
         1qrQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Gm-Message-State: APjAAAVBVT02MQAuMZ1RmQlgXXdAt/Lfh6ELKce4nLxG5fKMn3skHsNE
	SqmjIJD13r89KNFhuMi8NYtwFDQPm1YRC2K9uwrhkZ+PekF6bWGWiVFUqx7Lksad1YqKZeSxyEU
	yqEummUJZMAKC0lMKCkVHTAuzFJLRPlxwkwektUeaMrC1eqfv1+oqUBJDm4reCSedH+w7dhp8wn
	gcQby7fozMxeE/qEd0+y1w3x6IHSlHPXMrqxHqrjWbv3+npOQ3cZA5rAtXUsEVCV0u00ay/NlVp
	lNscfOW5Dcmuam2j+aadVUMLSoLNZWE23YZOGhXraNMkKM1x+7c4rXJOsiXdlFcjWA6U5EhAy/l
	g4X4mNa8HwmE8D4TSx8hpKUShmIuPQLR3iVnRzDGHd+h5AfDtyQVSJctRXvYt04TrsvtV3EPrw=
	=
X-Received: by 2002:a05:6830:1501:: with SMTP id k1mr33431436otp.245.1552596558486;
        Thu, 14 Mar 2019 13:49:18 -0700 (PDT)
X-Received: by 2002:a05:6830:1501:: with SMTP id k1mr33431389otp.245.1552596557522;
        Thu, 14 Mar 2019 13:49:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552596557; cv=none;
        d=google.com; s=arc-20160816;
        b=FGYPt26Mo1AH62uZNMBRSRe5n4U37HYlr+Xpe7la5DocM3eeY7YaLNjPf5MRxOqpE8
         5aQEIzodU+lC/rL2XUAAouM6PNum12PZZCwheADPIhw7Wz8+k1eR/zXFRnugmWVQtD90
         nwlCOancYNJxuXGGIZjg0Jpz3ACKxuyTbGzAjRtP0qTtbx2NUEW2sq0Eh5K/0hbGZsjK
         sl150i+4ZDI2oI25pAbVbvSvRgGHDI3MOlqldh/7RWk3KVMZZXmm2nd8uDu4u67ZVLyZ
         22TXTDb7+4xbqVBHRjhZnfYZK3pY4P8kkTIn9J6lJ3NfeV8WP/+LigqovzhZUp5kAd/2
         RTsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Wt8gOJHFNkRgmDnlN6CzGFr6EJDxliPV9hJpCDt7EGo=;
        b=JAn8HVTiUGGfxKr0EMe/qKeWp3RaqnM0LOcofCD6qL4aLqUYjfcxslYriOjHtna/Zo
         qnIVnrJcx0+JSsVv+qZoGV4tQaaQOVRZbETw6xN+L8V7vPJU65FAF3LV/M8W7mR/NR6a
         2P9ci4lleg3kH+CDSsUoqNrCmuZUkIcKlRhH4kymOVAEWMHhQ9Z+YBGm2KfQpFSo9vRm
         PA0smCCF9nnPsxJ9i0tiGqa/bWe+Jfe2oq+kTl32f3jyYowQLzJ1sYTXhNL4IRTdFHhS
         /7dImoSQyBTPld3HZulGVSrQpYRGmka6Plz4MFKUyuizDZNOw3Yxmj5VNAdErdJ/wLxt
         vlDA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e4sor32811oif.133.2019.03.14.13.49.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Mar 2019 13:49:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Google-Smtp-Source: APXvYqzJniSbh5HRjo72T9qstZDGb7JgiFghb3SsQXdE4S/CQaQ7WibPgL0TxWG1ub/BYjnvsmcb2g==
X-Received: by 2002:aca:2315:: with SMTP id e21mr303777oie.33.1552596557096;
        Thu, 14 Mar 2019 13:49:17 -0700 (PDT)
Received: from sultan-box.localdomain ([2600:1700:7c70:1680::21])
        by smtp.gmail.com with ESMTPSA id j21sm6058175otr.28.2019.03.14.13.49.14
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 14 Mar 2019 13:49:16 -0700 (PDT)
Date: Thu, 14 Mar 2019 13:49:11 -0700
From: Sultan Alsawaf <sultan@kerneltoast.com>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Christian Brauner <christian@brauner.io>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>,
	linux-mm <linux-mm@kvack.org>,
	kernel-team <kernel-team@android.com>,
	Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190314204911.GA875@sultan-box.localdomain>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAEXW_YQMnbN+e-janGbZc5MH6MwdUdXNfonpLUu5O2nsSkJyeg@mail.gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 14, 2019 at 10:47:17AM -0700, Joel Fernandes wrote:
> About the 100ms latency, I wonder whether it is that high because of
> the way Android's lmkd is observing that a process has died. There is
> a gap between when a process memory is freed and when it disappears
> from the process-table.  Once a process is SIGKILLed, it becomes a
> zombie. Its memory is freed instantly during the SIGKILL delivery (I
> traced this so that's how I know), but until it is reaped by its
> parent thread, it will still exist in /proc/<pid> . So if testing the
> existence of /proc/<pid> is how Android is observing that the process
> died, then there can be a large latency where it takes a very long
> time for the parent to actually reap the child way after its memory
> was long freed. A quicker way to know if a process's memory is freed
> before it is reaped could be to read back /proc/<pid>/maps in
> userspace of the victim <pid>, and that file will be empty for zombie
> processes. So then one does not need wait for the parent to reap it. I
> wonder how much of that 100ms you mentioned is actually the "Waiting
> while Parent is reaping the child", than "memory freeing time". So
> yeah for this second problem, the procfds work will help.
>
> By the way another approach that can provide a quick and asynchronous
> notification of when the process memory is freed, is to monitor
> sched_process_exit trace event using eBPF. You can tell eBPF the PID
> that you want to monitor before the SIGKILL. As soon as the process
> dies and its memory is freed, the eBPF program can send a notification
> to user space (using the perf_events polling infra). The
> sched_process_exit fires just after the mmput() happens so it is quite
> close to when the memory is reclaimed. This also doesn't need any
> kernel changes. I could come up with a prototype for this and
> benchmark it on Android, if you want. Just let me know.

Perhaps I'm missing something, but if you want to know when a process has died
after sending a SIGKILL to it, then why not just make the SIGKILL optionally
block until the process has died completely? It'd be rather trivial to just
store a pointer to an onstack completion inside the victim process' task_struct,
and then complete it in free_task().

Thanks,
Sultan


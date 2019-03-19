Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95AC0C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 23:13:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39E2B20857
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 23:13:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="JrlqfrSs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39E2B20857
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA35E6B0003; Tue, 19 Mar 2019 19:13:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D52846B0006; Tue, 19 Mar 2019 19:13:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C41DB6B0007; Tue, 19 Mar 2019 19:13:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6DC146B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:13:37 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id o9so198765edh.10
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 16:13:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=g8NtRy0L24nPh/xKsGU99NSGXQph+aEcmS1z6d1TxzA=;
        b=d3QIq0AkLTYMLDP0+vvWuwA+/T6HE3L4OPNe7WQOSHruwbEFs2p6jYARXwdbOYMkby
         qix3r1lK9sFKm4igLUn8/L1Ew9PW8zakR5Tsktw/oW0sBvm1oqgCUnUlGLdg6eV909f3
         Tn/zZCGo1zidA/xAKdSeBFoRDdHS0mV2NVU0tPsfXJuDOY69jXStGm5nluscfy50/JbV
         k1ZLu1Txr3lrlA7LeOC4c9ZYGH838Da/HYHIhaqj9cNT8l6bX5QZaro4tyxxytYXPclW
         kIMXyT/UzAGE4M5d8dePACEnXVmzjc4bgzpXhIYlpIxiXUyDKwrWraYgax/OGMncq5Ca
         Lm/w==
X-Gm-Message-State: APjAAAUAGnptBBcpLVh6OyAT5uhh1oVNHhKur8qSVTW8W/4AlQrHBu+k
	qRhfdYcQQ9oLGZ2EQEOA7bpXDHY+LHJOj+JymoQS+uzGMK3J65jO97L4Ti5+V5EEEaX7sTO2RBp
	iduKtJXYzlv+1PNRFHzQ3YcbhKuxCMzW48NbIMJCvWDM1nCoEVPAn7p16/lSzPtRGrQ==
X-Received: by 2002:a50:bdc2:: with SMTP id z2mr17664255edh.157.1553037216915;
        Tue, 19 Mar 2019 16:13:36 -0700 (PDT)
X-Received: by 2002:a50:bdc2:: with SMTP id z2mr17664223edh.157.1553037215953;
        Tue, 19 Mar 2019 16:13:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553037215; cv=none;
        d=google.com; s=arc-20160816;
        b=frw2M6fD5OFWf3wdO/9EEySlpowQLOMZqecnTysasdSiOlM9GkwcG+/eLk+4NRCHpR
         q6z2vC4YjglMKRpNJ1wI6nu8SfwzVOkWyIZlNnDAZGFe0vJiLo2Ny6vq19F2ucWb5Xt4
         GRl9sD7ob67xknhYORhImVEdoTn9IU11dClzPBq3oTuJpTYyQv8/dfGmjkP405HwF5YS
         QW246gi/nGlTHppC0qCO7V3sJiweFZR1g89BD2DRFYSgQoxrH18lbHvjqJQkPFRNiMOi
         f7iQGGzneHjqki5hZR02C4qp+TgTrfb1d0JG5acx0bUaF2awrDCn+UpmLsmLx9fDiGYU
         utyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=g8NtRy0L24nPh/xKsGU99NSGXQph+aEcmS1z6d1TxzA=;
        b=aND8FQLvkPyZnyI0wdJgR1yOBC73v5hmKa2fS7URdvSYud3w/3jeJ0/jyaoGdUIdQU
         NjWVY4Coe48KUwBkXZ77a4FDPng62hwQMSd9loKQYbgDt3G5sWpnxGsvVP6fC/dZOryu
         PhE9geJuy4XlPRFpLpZptXB4jdMzI6X6EPAFh58LmWsQnacU4bBLX+jr4DwIcnu/pIKg
         cZ+MhxIqGh7e7GdN0czFMvuppfsTjdVHDmDF9fen9+h/g2Z3B7X4CgIwUsBXmUKOaC0W
         hSjNWLhrBEjGEWOclfD7cUXkap7yESD55Z0KlLfj8afy13SRuty2GkkLhzuYMzGkbDw/
         sWag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=JrlqfrSs;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w19sor73419ejv.42.2019.03.19.16.13.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 16:13:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=JrlqfrSs;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=g8NtRy0L24nPh/xKsGU99NSGXQph+aEcmS1z6d1TxzA=;
        b=JrlqfrSshPWbtCUAUrRPqA2ImpfYXOgaC+IfRIDpdWuoWxlni7qxnHcDgFcNJlKp4C
         B/qYJsX/rNCYLQHnuELxcJcVMnrYBSIMTH25LH1NpUdG8mxpF8tITdCEvLIUu+q8v+Z0
         eQt+WbkPhaVIOARG31FKiWt+ZHh163cMVDolAD9WO0+IDp4YDx91+kMy4eHsFYIgmqPH
         9AONJaF94Df/w/GtVfU1jaoJ8Mr+po8Z49RLXxNbJ7eaOeeObo/0YRRrrdh/WHL9sei3
         LCWSE80Beg1Xsc8Q+SrAKzBOVJDQq7fTCWPEC7qgR98LgViSp/o6pqfWThRkCzWRTXDy
         M1fw==
X-Google-Smtp-Source: APXvYqzZ82VDtyWc+s831sp5Opp21O7qaftXQYQcET3CRx3ckdDa7bJqqHsj12xMmz5eNzcD6Ac2O+c3jBuue51JOiQ=
X-Received: by 2002:a17:906:288d:: with SMTP id o13mr15627170ejd.66.1553037215643;
 Tue, 19 Mar 2019 16:13:35 -0700 (PDT)
MIME-Version: 1.0
References: <CABXGCsM-SgUCAKA3=WpL7oWZ0Xq8A1Wf-Eh6MO0seee+TviDWQ@mail.gmail.com>
 <20190315205826.fgbelqkyuuayevun@ca-dmjordan1.us.oracle.com>
 <20190317152204.GD3189@techsingularity.net> <1553022891.26196.7.camel@lca.pw>
 <CA+CK2bDhB8ts0rEc46vVT-mR8Avx=DZAdyMTzxqOD99MP7dOEQ@mail.gmail.com> <1553024101.26196.8.camel@lca.pw>
In-Reply-To: <1553024101.26196.8.camel@lca.pw>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Tue, 19 Mar 2019 19:13:24 -0400
Message-ID: <CA+CK2bA6J_BT9C=-ohezTj4L9TV61GCi9MsKbhGO4ZtEBvdkeA@mail.gmail.com>
Subject: Re: kernel BUG at include/linux/mm.h:1020!
To: Qian Cai <cai@lca.pw>
Cc: Mel Gorman <mgorman@techsingularity.net>, Daniel Jordan <daniel.m.jordan@oracle.com>, 
	Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>, linux-mm <linux-mm@kvack.org>, 
	Vlastimil Babka <vbabka@suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Thank you Qian, do you happen to have qemu arguments that you used?

Thank you,
Pasha

On Tue, Mar 19, 2019 at 3:35 PM Qian Cai <cai@lca.pw> wrote:
>
> On Tue, 2019-03-19 at 15:27 -0400, Pavel Tatashin wrote:
> > > So reverting this patch on the top of the mainline fixed the memory
> > > corruption
> > > for me or at least make it way much harder to reproduce.
> > >
> > > dbe2d4e4f12e ("mm, compaction: round-robin the order while searching the
> > > free
> > > lists for a target")
> > >
> > > This is easy to reproduce on both KVM and bare-metal using the reproducer.
> > >
> > > # swapoff -a
> > > # i=0; while :; do i=$((i+1)); echo $i | tee /tmp/log ;
> > > /opt/ltp/testcases/bin/oom01; sleep 5; done
> > >
> > > The memory corruption always happen within 300 tries. With the above patch
> > > reverted, both the mainline and linux-next survives with 1k+ attempts so
> > > far.
> >
> > Could you please share copy of your config.
>
> https://git.sr.ht/~cai/linux-debug/tree/master/config


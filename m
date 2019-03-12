Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B1BAC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 18:43:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E18B7205C9
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 18:43:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="OwoZi4sC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E18B7205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6ACD98E0003; Tue, 12 Mar 2019 14:43:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 65DEC8E0002; Tue, 12 Mar 2019 14:43:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 54CD38E0003; Tue, 12 Mar 2019 14:43:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 386128E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 14:43:26 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id n15so2512481ioc.0
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 11:43:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=fo/v7SBqR9Y8HorvRV4qY+qTc74qy6r2ZpOJax4E0b4=;
        b=OVAKkvvHt01TeojEtfpAOugNP7sBTnXagZgCdhkI7RNw9WuKiP39YfmkyzV4AsNB86
         fD19x2Xd1SoqgftuoubPE+vnufmSs8Hn0puz5mKMnEdt8b/0/nPkbsRepmPgeEnFTtk4
         /M92m4udNeR/mpHvYGhnWoJT2//JekQO36jsm2ET9w98eYEd9HuMQ7jREycWbTShwCiC
         G/YUghLo2XxO1Dkm0zMDwSa7SiS5N/jSbEoVaeDqlOMLfJNZwdAFiqN6ws66TErVwmGn
         3R6jvPRHlLHLNr3bVdsn+HYxPccXrPKLvPuGRhqxO/VHJ0NM9zCzEmuHn9c2GdrWlFhB
         g1ng==
X-Gm-Message-State: APjAAAUdEuQoVGHsTakvgNq7reK5UP0nnfFGoXWRc/0UXzHyrd4ABPYL
	JrYZ6W3lk/2o2NsyJuNHDfCbfUuthZ8WiwFsmCoI3YFQ06UIPuHybxW/NWk/tO57xyzN2amD6fp
	1kc9QlfJpphjBgA70HApwLHJJ6CAyC37GVGEhOJXKr0kcuSpqrrn2/WYNPjv9i5VCXtwC6nLZ/A
	je3LRvuVg7GFNH+X+Epc9SL254Ei7vOxtFbjDEEQPKgYcSovh/pGPT2J38BodTsYO6T2/HfUkZl
	T/1gRuQoJa1WXZppi7kljCOvayUa2DnmVq7Ly6Mv7DInz6tBqiR5eew+UjJfwLYj6zJDgcsQLba
	ntKR9NCn65SL2JjOyxvO0QRX3HSElZZ2Lb3Dk5mV53OYhuRp8+wgDi503BtW4O+3hfI1I5rnysM
	H
X-Received: by 2002:a5d:984a:: with SMTP id p10mr5567693ios.217.1552416205967;
        Tue, 12 Mar 2019 11:43:25 -0700 (PDT)
X-Received: by 2002:a5d:984a:: with SMTP id p10mr5567671ios.217.1552416205241;
        Tue, 12 Mar 2019 11:43:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552416205; cv=none;
        d=google.com; s=arc-20160816;
        b=HUS7y2D6uWmBpFAkNdRVXZS32Yk5nRlyFQSyEgTMq1m4ecHQ6jBUvIOu2g0Ni2BUl0
         Lix7+YlbR4dQurbWlSsshgv5rSRjwcuxY4RHpEDgTJ1FIVhAq2NKGyOg+wXDhVKDf8eG
         STafoK6YewOIGNadVdu9DxsFoAH8lnEXtYoPgrTmwTNy3+VdaaFKn1y27C2dXPsKEPQb
         fVJr10LMfvlj/uJDHQehbzVv39Wbcfh2+zgsxmEO4QldBDAwVLLwmZbSHmjntK7+ck+D
         HFr6XkS1TDbI7bd5Y1hJVTr6WfuJPLYru7jWubTmOscFk2alpfyuw+tYkVnuDuJ0BRad
         ANZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=fo/v7SBqR9Y8HorvRV4qY+qTc74qy6r2ZpOJax4E0b4=;
        b=qW/4UQhO3fp+6IiFs22sF4hEw62fX8hXmHRlYo0GYYh5eDkRv2pTG6Fz6ThAe5UgsE
         l8a9nOiDwvMo/JCU9PUoQQ87et2OD4oU/moxugnIkKeWdvh8uTzzdsMq6VgCZpSDDSLF
         YqKwnEg2Rha+I4eHOYSSJH7t6YxFoDCQyHyemZ8c/UssL3044aY63fRp6F6/9LZg0NAX
         jWCqlz0VFCFf7gNQyXOdWhGznCeOYtjgQ7bTgyRT4oJb1DFlomsOPgUEWbMhDFe10c+q
         lWx0xsi01weffz57GcGOGKljOtzQRQEWIxi+YeN03Q8VMOP2RiDYMpDJ5F47hKO0UoF6
         Dm+A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=OwoZi4sC;
       spf=pass (google.com: domain of timmurray@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=timmurray@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s25sor2387160iol.28.2019.03.12.11.43.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 11:43:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of timmurray@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=OwoZi4sC;
       spf=pass (google.com: domain of timmurray@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=timmurray@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=fo/v7SBqR9Y8HorvRV4qY+qTc74qy6r2ZpOJax4E0b4=;
        b=OwoZi4sCHLXm6jIB0SrimzodzEpnuPM1ocHav7KTqC/dNINfGz1ZTNNM/Qor4MM/g0
         N+4QizOgiWx6nzvYXPvQ/Cv4V0+kOKHlBD849Q6u93IR06hIERUU+zCuFjk+zYBU0hVW
         +9wA5VDFmCWUJQo4t4/PMQqmEY68hU97RT4cDqmb03LNd8WglTVlQSADJx8bOSlnFh/h
         IM6esZI0z3TL94uA0L3h1/beuuBxUp2WaMn2DAMWX4EW2ypY0Ylq3Lr8IdGG/Z4WJy+L
         nTpuBSvtJn5K6TfhDU/Iupb3+Qq+u8M1sDN4xRN4LTInedhd+UXZkbovRG74KnkZKRpC
         N40A==
X-Google-Smtp-Source: APXvYqxl7+sqyVCZd0nlCLusQ7k24/I/mt+5W6Z1PdcID4CmgBm88PBxwF51+PonJKlNy38PiMl+aatep/V5nuxT7XQ=
X-Received: by 2002:a5e:db0d:: with SMTP id q13mr425229iop.279.1552416204862;
 Tue, 12 Mar 2019 11:43:24 -0700 (PDT)
MIME-Version: 1.0
References: <20190310203403.27915-1-sultan@kerneltoast.com>
 <20190311174320.GC5721@dhcp22.suse.cz> <20190311175800.GA5522@sultan-box.localdomain>
 <CAJuCfpHTjXejo+u--3MLZZj7kWQVbptyya4yp1GLE3hB=BBX7w@mail.gmail.com>
 <20190311204626.GA3119@sultan-box.localdomain> <CAJuCfpGpBxofTT-ANEEY+dFCSdwkQswox3s8Uk9Eq0BnK9i0iA@mail.gmail.com>
 <20190312080532.GE5721@dhcp22.suse.cz> <20190312163741.GA2762@sultan-box.localdomain>
 <CAEe=Sxn_uayj48wo7oqf8mNZ7QAGJUQVmkPcHcuEGjA_Z8ELeQ@mail.gmail.com> <20190312174520.GA9276@sultan-box.localdomain>
In-Reply-To: <20190312174520.GA9276@sultan-box.localdomain>
From: Tim Murray <timmurray@google.com>
Date: Tue, 12 Mar 2019 11:43:13 -0700
Message-ID: <CAEe=Sx=MxzBB46WxuwHTQcocBkx1UW+fmVOa3VWv_eUferzVYw@mail.gmail.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
To: Sultan Alsawaf <sultan@kerneltoast.com>
Cc: Michal Hocko <mhocko@kernel.org>, Suren Baghdasaryan <surenb@google.com>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, =?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, 
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>, 
	Joel Fernandes <joel@joelfernandes.org>, Christian Brauner <christian@brauner.io>, 
	Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, 
	LKML <linux-kernel@vger.kernel.org>, devel@driverdev.osuosl.org, 
	linux-mm <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 10:45 AM Sultan Alsawaf <sultan@kerneltoast.com> wrote:
>
> On Tue, Mar 12, 2019 at 10:17:43AM -0700, Tim Murray wrote:
> > Knowing whether a SIGKILL'd process has finished reclaiming is as far
> > as I know not possible without something like procfds. That's where
> > the 100ms timeout in lmkd comes in. lowmemorykiller and lmkd both
> > attempt to wait up to 100ms for reclaim to finish by checking for the
> > continued existence of the thread that received the SIGKILL, but this
> > really means that they wait up to 100ms for the _thread_ to finish,
> > which doesn't tell you anything about the memory used by that process.
> > If those threads terminate early and lowmemorykiller/lmkd get a signal
> > to kill again, then there may be two processes competing for CPU time
> > to reclaim memory. That doesn't reclaim any faster and may be an
> > unnecessary kill.
> > ...
> > - offer a way to wait for process termination so lmkd can tell when
> > reclaim has finished and know when killing another process is
> > appropriate
>
> Should be pretty easy with something like this:

Yeah, that's in the spirit of what I was suggesting, but there are lot
of edge cases around how to get that data out efficiently and PID
reuse (it's a real issue--often the Android apps that are causing
memory pressure are also constantly creating/destroying threads).

I believe procfds or a similar mechanism will be a good solution to this.


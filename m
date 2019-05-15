Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7C53C46460
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 14:58:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 808BE206BF
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 14:58:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 808BE206BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 214FF6B0003; Wed, 15 May 2019 10:58:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C6526B0006; Wed, 15 May 2019 10:58:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08E286B0007; Wed, 15 May 2019 10:58:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id DBCB56B0003
	for <linux-mm@kvack.org>; Wed, 15 May 2019 10:58:53 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id n65so2485845qke.12
        for <linux-mm@kvack.org>; Wed, 15 May 2019 07:58:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=tszhKujCKsRERdzN5TNEwD05H7rg2No04ol0gNO9QuM=;
        b=hmB54Nk4zn6gKXFWTRVscVHvlFL3EnX01LRzXruEVhRdU01H9bDsTWqby0MxmlASFU
         SbzswjtKJon/V+UoU5vuYNYuru8/RfhxjD3x6bZKNnbmpUHlAcTmsesKbghIRdw/Ls+d
         er9J3o79tU7VzKBgftTA4ycCvsIvVIhVOnFi8Xk/GoESxf9wgWs6Ze/T1qXEcIlf8XwE
         bITrOjpruKzHAa9f/fc08UQTE+9A5sQwMV4YV1hrfnpl+tqyQS2FIWCzIbZNNw6jRSEG
         PVamk5OFL6uq5Aoq/buzYThkNgBylbPJrQvBpywUkphYX0eH+L1vwkLchyFqzpLHQ0+w
         RT0g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWg4G/+htz+NDKO9NLnRf846V2Tri85PJr/XPwHTMhFNQnKAsyA
	2ohV2l4C2z30JytdUC4GKdpGlC0KC9JQ9LSyH3vzIoaVmovXipqG+UvTWZdIAtYnVWEmNmVd5/S
	As96KSA/ZCIdQjqVX/EOfbBMYsIjZNGWYAvIJVoHe1CZJxUdAsCypOlUtZw8M2qYBdQ==
X-Received: by 2002:a37:4d0d:: with SMTP id a13mr27659970qkb.143.1557932333638;
        Wed, 15 May 2019 07:58:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFdHYV4GMmmNbEj0JfzeBdCt7JT0wtmXGqjgdrAst0hRqkey3xcxASQkS1JhGPR64Mg7hE
X-Received: by 2002:a37:4d0d:: with SMTP id a13mr27659933qkb.143.1557932333040;
        Wed, 15 May 2019 07:58:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557932333; cv=none;
        d=google.com; s=arc-20160816;
        b=z0sb47yWh/x1c+49d5PgL1tiMpe0f3rxjl+9CPQPuJPoixwiHwoxhmTN+9yAdvjEMO
         0f/ukXrOQoSTWLMxXwVbW2tLF+E5o2avdxlqKhF/qtd1jR8OtDShRgysZ4D8eiOySHoq
         48AtSUlprl9R30vk8scLB5adsp115y35vDXGs5wD4Qjlq3dB6IftiWKI0tj7m3x03Ru+
         vcbsgRbFpyrwFilKBuubfhYhQsisHfRGJNXhNEKo2SF4KioNcYVSESZSRUJgmKYvbewv
         y1tvUmE+WXe656XbKjK915a6EheDlCypUAzsp0eeoov/pAK4h2w0tg1QJ5u/azBDUqbL
         l7ag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=tszhKujCKsRERdzN5TNEwD05H7rg2No04ol0gNO9QuM=;
        b=Wu+nhosXIR3RBsnvCp/bXZ9JiZN0Ut/yKgHlW6t3HDlNsn+L+eQYcyrkmvmQLFlspu
         GtM5ol/dPg/GkT9D4l1RKS+ElYdwiDyrLGjXFKoru8MzVKz3CsmFqzYzHFtnkpa6xQEg
         7YN+cm8rh4hsgMcgqqg3wZRRmAV634QqAyJyPdTKncGOAiUwvD9uTn5tx6zOrLpIV1Qc
         qjK23gUefVWPrcOsmt+dkOOtzYXNtNQtZWSVBlvx2TgwI69IEXVC3jxgbA6O+/aPNhkm
         akcGz71a14z4MdV3OtTEfH8ZSNtkHnMdMnuWcudNgLFjjfnb7O4HGSEkPLTU2Lj2TToo
         gjIA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 55si344295qvv.71.2019.05.15.07.58.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 07:58:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9483430BB36D;
	Wed, 15 May 2019 14:58:41 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.159])
	by smtp.corp.redhat.com (Postfix) with SMTP id 8F97719C7C;
	Wed, 15 May 2019 14:58:35 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Wed, 15 May 2019 16:58:38 +0200 (CEST)
Date: Wed, 15 May 2019 16:58:32 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Sultan Alsawaf <sultan@kerneltoast.com>
Cc: Christian Brauner <christian@brauner.io>,
	Daniel Colascione <dancol@google.com>,
	Suren Baghdasaryan <surenb@google.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>,
	linux-mm <linux-mm@kvack.org>,
	kernel-team <kernel-team@android.com>,
	Andy Lutomirski <luto@amacapital.net>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Kees Cook <keescook@chromium.org>,
	Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190515145831.GD18892@redhat.com>
References: <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
 <20190319231020.tdcttojlbmx57gke@brauner.io>
 <20190320015249.GC129907@google.com>
 <20190507021622.GA27300@sultan-box.localdomain>
 <20190507153154.GA5750@redhat.com>
 <20190507163520.GA1131@sultan-box.localdomain>
 <20190509155646.GB24526@redhat.com>
 <20190509183353.GA13018@sultan-box.localdomain>
 <20190510151024.GA21421@redhat.com>
 <20190513164555.GA30128@sultan-box.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190513164555.GA30128@sultan-box.localdomain>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Wed, 15 May 2019 14:58:52 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 05/13, Sultan Alsawaf wrote:
>
> On Fri, May 10, 2019 at 05:10:25PM +0200, Oleg Nesterov wrote:
> > I am starting to think I am ;)
> >
> > If you have task1 != task2 this code
> >
> > 	task_lock(task1);
> > 	task_lock(task2);
> >
> > should trigger print_deadlock_bug(), task1->alloc_lock and task2->alloc_lock are
> > the "same" lock from lockdep pov, held_lock's will have the same hlock_class().
>
> Okay, I've stubbed out debug_locks_off(), and lockdep is now complaining about a
> bunch of false positives so it is _really_ enabled this time.

Could you explain in detail what exactly did you do and what do you see in dmesg?

Just in case, lockdep complains only once, print_circular_bug() does debug_locks_off()
so it it has already reported another false positive __lock_acquire() will simply
return after that.

Oleg.


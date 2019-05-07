Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DA0AC004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 12:26:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC7C12087F
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 12:26:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC7C12087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 54EF06B0005; Tue,  7 May 2019 08:26:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4FDE56B0006; Tue,  7 May 2019 08:26:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C6E96B0007; Tue,  7 May 2019 08:26:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E46736B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 08:26:18 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id h2so13373262edi.13
        for <linux-mm@kvack.org>; Tue, 07 May 2019 05:26:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=TQJGh89jqr7YwcON0kZF1qO2P0193iEg9GyRYpzZSEo=;
        b=R9frCGduQFcnFOd18WOJtZiv0PN56niSIp9uiH3j1ETzEByhKM3SHkesvu3m0Pajwz
         fkufqninudw5GCM59QqnfZUb6h5l7CB+9qbPLx/z4WCleWF368IMzEWRBdXMDXnoyGlP
         McrBWGBC8a6FVNuz2TD6fJWTyxRLFlhV9XI7+Pv9JrJDkWtvzaXyuyJzitfLiykAiOHd
         c1EWCHnlv9z9hfNMPXo7YnDo5nWdMczLKet0tzQeB0LGw3YaftzzfQV820yZrO8t8oVc
         KqOI6hMTstKzMBmL3N/Cxjgte6GkSV7wP/j4IjQVHYrZL4Br7Nc0FxsWxpsrFsssLkzN
         CsNQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXpknzu3fP0pt+B57diRBNiKMR5BC8VQ1mvQxJRyu0vaksyQaL8
	Bg6RHGfu+tkzKd33gDCNwgz5INY7PQtelWBgLOOvcWtDkQK25kJ+/vCM0xHS6InP/Dfos85W3f+
	UvsEOe6jlWL6uQrRJrWlI3bq1Prg11NlnPQ+qSFf3z9GrltVNbZk6Dievz5Xii9M=
X-Received: by 2002:a50:be42:: with SMTP id b2mr33879919edi.228.1557231978497;
        Tue, 07 May 2019 05:26:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwiaj/xMC/Qokuz2H0sv1IseAqnaXcnEHNkkf6BS2LJUUbSVS2R9xqSToNM2QeSZe26DsYg
X-Received: by 2002:a50:be42:: with SMTP id b2mr33879838edi.228.1557231977752;
        Tue, 07 May 2019 05:26:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557231977; cv=none;
        d=google.com; s=arc-20160816;
        b=jZw5GQIXaupbrw9uTEBUuFIpblNB8NwGrtroE4q2cQcn2gnVesw6OLGC0okLr8Gosm
         IB9WeJZlaGe0Ls3qoZ0oNzS82N3qurZcv0IStOfr9ImaZRZv9Nmn4HbTKpvzUZOHl+xo
         RM03WoTN6+hiy/N3bWZG9IT70OvUV0KmvNZmlxxKidLqiLZfX5A1nmUwb5nqS7CeZXH2
         QKQrU9obHFX2VSJQOqyuMavyWsDQDzwYJvZ3Nej+a9JLQDjvhYZfoC1SvVxe6qnzRXb8
         cZFLwQNNMNWH2IKKrqIKwGEe+V5c8uVeRZ2Zki3CdILm+665WGyycYac4AuJ5BVUKE2N
         a1Vg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=TQJGh89jqr7YwcON0kZF1qO2P0193iEg9GyRYpzZSEo=;
        b=yIFn03D5Thz5MJDuBulIL9hBSJuj0UOuOCgXrfcdFX6m7Fg91jN3ogqxvnVUhxurkJ
         rcvibZKeiFQd1Moud1cldUHvJURrjxcu2zIfM2eNMv3+zRCHwMLpMpYncuexFJ4BMv9T
         135hMZNY0HCIsgWqXLuHwW/cwo5k9FuumyDm3iaURjZr1IxCPyBYvmXVItOU2BWP54Lv
         5NdgTuyATGqCSz0PHKzaE8hq6pd+Zbq2Jhlm4rm4yptQEkH0W6b9MC5/mLIgt8wsOj5t
         lIGUP7at/L96j5KVYiujLhSdC3qeS1xEVg0OHLzpXlDIuxexSh9mvpk6kPPolvXGhM8n
         eGAg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b8si3118927ejb.230.2019.05.07.05.26.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 05:26:17 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DEFD9AC3B;
	Tue,  7 May 2019 12:26:16 +0000 (UTC)
Date: Tue, 7 May 2019 14:26:15 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Sultan Alsawaf <sultan@kerneltoast.com>
Cc: Christian Brauner <christian@brauner.io>,
	Daniel Colascione <dancol@google.com>,
	Suren Baghdasaryan <surenb@google.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Tim Murray <timmurray@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>,
	linux-mm <linux-mm@kvack.org>,
	kernel-team <kernel-team@android.com>,
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Kees Cook <keescook@chromium.org>,
	Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190507122615.GQ31017@dhcp22.suse.cz>
References: <20190317015306.GA167393@google.com>
 <20190317114238.ab6tvvovpkpozld5@brauner.io>
 <CAKOZuetZPhqQqSgZpyY0cLgy0jroLJRx-B93rkQzcOByL8ih_Q@mail.gmail.com>
 <20190318002949.mqknisgt7cmjmt7n@brauner.io>
 <20190318235052.GA65315@google.com>
 <20190319221415.baov7x6zoz7hvsno@brauner.io>
 <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
 <20190319231020.tdcttojlbmx57gke@brauner.io>
 <20190320015249.GC129907@google.com>
 <20190507021622.GA27300@sultan-box.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190507021622.GA27300@sultan-box.localdomain>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 06-05-19 19:16:22, Sultan Alsawaf wrote:
> This is a complete low memory killer solution for Android that is small
> and simple. Processes are killed according to the priorities that
> Android gives them, so that the least important processes are always
> killed first. Processes are killed until memory deficits are satisfied,
> as observed from kswapd struggling to free up pages. Simple LMK stops
> killing processes when kswapd finally goes back to sleep.
> 
> The only tunables are the desired amount of memory to be freed per
> reclaim event and desired frequency of reclaim events. Simple LMK tries
> to free at least the desired amount of memory per reclaim and waits
> until all of its victims' memory is freed before proceeding to kill more
> processes.

Why do we need something like that in the kernel? I really do not like
an idea of having two OOM killer implementations in the kernel. As
already pointed out newer kernels can do PSI and older kernels can live
with an out of tree code to achieve what they need. I do not see why we
really need this code in the upstream kernel.
-- 
Michal Hocko
SUSE Labs


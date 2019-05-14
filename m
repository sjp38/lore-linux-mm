Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF672C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 17:31:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD18B20850
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 17:31:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD18B20850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kerneltoast.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C9886B0007; Tue, 14 May 2019 13:31:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 479426B0008; Tue, 14 May 2019 13:31:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 340B86B000A; Tue, 14 May 2019 13:31:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 095616B0007
	for <linux-mm@kvack.org>; Tue, 14 May 2019 13:31:26 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id x23so3983288otp.5
        for <linux-mm@kvack.org>; Tue, 14 May 2019 10:31:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ErzBDF5ta8fy4S6axV5usgeVf1icUMn3T8UVynCsAWs=;
        b=WOGWsWinw4KlBxCsYk7frxI+9WyqI2uis/q1c6x524nkJ7i5t1kgbOopG2vbEW3rZz
         33zBFvSyK1VmZLYfZlyqkDsJzgqr2Gde/tKPJeK3gvsPVB0DSWJMhydJbbm0BynG7MDE
         KNu4qVZeDxGOm74i8vQ6qnR6cHrNZD9RhIFicUc+OkBJyslUuFoKWBPXBwCFroO8fTEF
         aIGB8PJN3EhK521KGedWP8ftDT4CCyyqhsVkk7e6sKZ5xmKar8Tve5xc0pQQaR5zM7Qq
         eyCLjtXpJ5Q9uujJnRwkR4PaPbCGBhrZ6fDwgqBOART6drppCddEsrJxF2bYLBeXKmTd
         7Wog==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Gm-Message-State: APjAAAWpzTCHvhXjtEPadU0Ih7cwV435TDO9DQn+OgUFtUikSrxw+KIa
	+ywvVbJX8zG7AwRcRkXc3DSXRO3/816kcw96bStqGvKy3/md/rpUWaXSTUhypt5OpoZ3C8iOnOb
	RlYbdM5y6PhZq+rHtvQG4skl2VDkvEr45XbN90WgbgSyENXCcejVT6Hab4qw7xQk=
X-Received: by 2002:aca:3f07:: with SMTP id m7mr3626820oia.179.1557855085649;
        Tue, 14 May 2019 10:31:25 -0700 (PDT)
X-Received: by 2002:aca:3f07:: with SMTP id m7mr3626764oia.179.1557855084765;
        Tue, 14 May 2019 10:31:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557855084; cv=none;
        d=google.com; s=arc-20160816;
        b=DCWLzHJGT8VMw/axn6ycAmFw4ECbU4gDBVbi4j/dV2nnjwy5gU1mnbCfFM1YbrXSv7
         IZHd7wHThHgNXWpKU71g21usF/ZRhtf4dA/FgyjD0m1BZFgBSqdvkLoc1ynrLjEJpAPB
         j3YGZnsNiVvHPt/udPgUhap3dD3cUvgW53t9lEl4IHsfpuHiLXLFbzoHcEldkQQY87X+
         09My0Yn3K3LFmPtVrdrzpxXeMfsq0hgUq33AnCdbn18JR+6M2mg1U0MXTFOWxmszddSl
         yfwOtg6lRPxMlSMfnFIJgEv8G2PN/UCjI2gXXpNvSKtorCOG9DycUeGTqDzOLsryLQqC
         EFKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ErzBDF5ta8fy4S6axV5usgeVf1icUMn3T8UVynCsAWs=;
        b=lWthQFgkWao9VZtR1us/Vjq42HnkdEHS8tubAhMOzm3RL3p1kihhsEBPkAhvSLJalQ
         0H9FEZvnW1uhP4iMWXYd1JcbgeNjXdhbb8D923juoPO4D0wB+aE+qDF+j7XXnP6W8h1W
         gPyGvHtEs0TD0LYvqKr4lSjKpC6CHBPDPY9uMzrhSyVNVR6YiNjopzIWPsswpNFQoowh
         Jd6+dBcTibLEd2bLQUmL4Co1dOjHFxNTh55I80jelGXDq57MmdLa1NpamhfVRTY6EZch
         8tMeYA1mC/ZVO4dEdCrfkTu3CJrpXx+AUltdYPzCQJebVFWLt0dW5d37Z7/ZrpJdHePR
         KEjw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h7sor895383otr.101.2019.05.14.10.31.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 10:31:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Google-Smtp-Source: APXvYqxkxGAxP4ZnVEYXQ1pF+uY0YgUE1LJnsi3HHxrq+TOlnXkjSIbH/bnYS6xVvJ3PilYfe8glmw==
X-Received: by 2002:a9d:362:: with SMTP id 89mr4306623otv.17.1557855084265;
        Tue, 14 May 2019 10:31:24 -0700 (PDT)
Received: from sultan-box.localdomain ([107.193.118.89])
        by smtp.gmail.com with ESMTPSA id m25sm6357027otp.81.2019.05.14.10.31.21
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 14 May 2019 10:31:23 -0700 (PDT)
Date: Tue, 14 May 2019 10:31:19 -0700
From: Sultan Alsawaf <sultan@kerneltoast.com>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Oleg Nesterov <oleg@redhat.com>,
	Christian Brauner <christian@brauner.io>,
	Daniel Colascione <dancol@google.com>,
	Suren Baghdasaryan <surenb@google.com>,
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
Message-ID: <20190514173119.GA19142@sultan-box.localdomain>
References: <20190319231020.tdcttojlbmx57gke@brauner.io>
 <20190320015249.GC129907@google.com>
 <20190507021622.GA27300@sultan-box.localdomain>
 <20190507153154.GA5750@redhat.com>
 <20190507163520.GA1131@sultan-box.localdomain>
 <20190509155646.GB24526@redhat.com>
 <20190509183353.GA13018@sultan-box.localdomain>
 <20190510151024.GA21421@redhat.com>
 <20190513164555.GA30128@sultan-box.localdomain>
 <20190514124453.6fb1095d@oasis.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190514124453.6fb1095d@oasis.local.home>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 14, 2019 at 12:44:53PM -0400, Steven Rostedt wrote:
> OK, this has gotten my attention.
> 
> This thread is quite long, do you have a git repo I can look at, and
> also where is the first task_lock() taken before the
> find_lock_task_mm()?
> 
> -- Steve

Hi Steve,

This is the git repo I work on: https://github.com/kerneltoast/android_kernel_google_wahoo

With the newest simple_lmk iteration being this commit: https://github.com/kerneltoast/android_kernel_google_wahoo/commit/6b145b8c28b39f7047393169117f72ea7387d91c

This repo is based off the 4.4 kernel that Google ships on the Pixel 2/2XL.

simple_lmk iterates through the entire task list more than once and locks
potential victims using find_lock_task_mm(). It keeps these potential victims
locked across the multiple times that the task list is iterated.

The locking pattern that Oleg said should cause lockdep to complain is that
iterating through the entire task list more than once can lead to locking the
same task that was locked earlier with find_lock_task_mm(), and thus deadlock.
But there is a check in simple_lmk that avoids locking potential victims that
were already found, which avoids the deadlock, but lockdep doesn't know about
the check (which is done with vtsk_is_duplicate()) and should therefore
complain.

Lockdep does not complain though.

Sultan


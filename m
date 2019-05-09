Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7CBFC46470
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 18:34:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C28A217D9
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 18:34:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C28A217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kerneltoast.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05EC06B0006; Thu,  9 May 2019 14:34:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F02F16B0007; Thu,  9 May 2019 14:33:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D7CEF6B0008; Thu,  9 May 2019 14:33:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A01C66B0006
	for <linux-mm@kvack.org>; Thu,  9 May 2019 14:33:59 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id t1so2161801pfa.10
        for <linux-mm@kvack.org>; Thu, 09 May 2019 11:33:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=yqiI+x42OXIbUvTBPZc5iTEkpFbz64YiBLYaRAWuA0c=;
        b=h7YBt7DUtBr5/CgWGXj1BaLWseI9quUybM+R4RpS+EZo/jfxLA20BNWAqKY8e+F9VZ
         ZW3m27/MfBrCXNHTLwfdCz7Nuvf9r++Adad7mU/pLp86ZuHW8fqPP7dLk9auqoYcvDQ9
         ifb9JNG67wmzrERgD9HpZEtYI0/c/pJ6NpkBrut/I/zNdIgUFKGHchoXMmSvSBQzWFXO
         QDunkK9S3gj1e2IdFY5XyRkw6Pe39H88FrvSQGpIrnGrcHGQMkiNcn144pK8K0hgHJcB
         aNnc1N4alqGkvFKMjBLzxzktVVB0sK19egqvPPJnR2w7KGYrlCBgzd4L5kkAzUIxa9pq
         OneQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Gm-Message-State: APjAAAV5wfbphuZTbeWnUXzF5pNmMv2V5yceyZWC+4G+hz84Xb2Vcpkv
	JguRaMLmx9fsFrKX4MgJ3S10FXgBRIMccA110wBjuqydQUX1Rfmrt1XOE48dKrfsTWoCwcewtRs
	Vk24Mw8mYnhMoTq8bNzFj4fbmCUfF4wioDEm95TmdLtHyK3gJpkXgodgAAiwKAtk=
X-Received: by 2002:a17:902:74cc:: with SMTP id f12mr7197526plt.213.1557426839291;
        Thu, 09 May 2019 11:33:59 -0700 (PDT)
X-Received: by 2002:a17:902:74cc:: with SMTP id f12mr7197412plt.213.1557426838262;
        Thu, 09 May 2019 11:33:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557426838; cv=none;
        d=google.com; s=arc-20160816;
        b=s3/hupx2PT2R8stKFpuQrLj5HyyhhFLySK59mfqP4co6QtrPEr/I4re6dTf1mbPLFZ
         H3QFTkDj196C0++Qc0atnoNLmdjthOCvwX87y24pJnVVK6iMD2aH0gyqY/LwSvVd/GlP
         8T7ZYfrUIljompD/n166RNByOEiAhMRNr8BS17RkZ/+ExSq+FH9ydSmEErauKmahqujc
         DmeifIkeFnnr4KTJmW5pJBK3LX0hTnxRUCApW+Wd5nU8AtyXajGvA3zaAeHd/uza2Um3
         IT0C/MuYibbDiTb4/VOhy6FHVz9HXCKbM9W7yDyxuH0zHn7dDr4btOGRDZWLCiFrSyAS
         zbog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=yqiI+x42OXIbUvTBPZc5iTEkpFbz64YiBLYaRAWuA0c=;
        b=xVN7WHOOXBL/6wuBlRvCVkStfvezLOFyY3XmyurUbXPejSWJGdSSN2pa4bhIPOSfbY
         sq1avXJg4TUpVgdBmtaoWaegUepHzKodGGAj1+vu1/0Xm0yUxMvWjy//3Z+Ta8OvTa/y
         dAHL62VgiVzWtqa9HTRBhKwyI7/MP3jHTJwlPZeVDat1E2F42nbRjVkNhPxTAuPSuMdL
         QSOIBArpSToFRvbyVRkKtiObkFOSaNzVw4ePDLSwj2gR+Hk/KZyOeaQdvEnpDgc8jKCq
         wv81F+hbryqj7oNHf5je+SpKgnSrRXUz57CZ37DqHVYfs3czmKs+xQBuBfjyBLtS0qkD
         zH8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u14sor3809527pfl.8.2019.05.09.11.33.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 May 2019 11:33:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Google-Smtp-Source: APXvYqyEc1uZevZKY+jNDHPdN0qC+8kcKlru+7ZgfAEEO+vBJPv7McdJDqNHLDhPTA7XqyJ/yigK1g==
X-Received: by 2002:aa7:980e:: with SMTP id e14mr7485557pfl.142.1557426837664;
        Thu, 09 May 2019 11:33:57 -0700 (PDT)
Received: from sultan-box.localdomain ([2601:200:c001:5f40:7687:d078:2931:7298])
        by smtp.gmail.com with ESMTPSA id o2sm7914179pgq.1.2019.05.09.11.33.55
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 09 May 2019 11:33:56 -0700 (PDT)
Date: Thu, 9 May 2019 11:33:53 -0700
From: Sultan Alsawaf <sultan@kerneltoast.com>
To: Oleg Nesterov <oleg@redhat.com>
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
Message-ID: <20190509183353.GA13018@sultan-box.localdomain>
References: <20190318002949.mqknisgt7cmjmt7n@brauner.io>
 <20190318235052.GA65315@google.com>
 <20190319221415.baov7x6zoz7hvsno@brauner.io>
 <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
 <20190319231020.tdcttojlbmx57gke@brauner.io>
 <20190320015249.GC129907@google.com>
 <20190507021622.GA27300@sultan-box.localdomain>
 <20190507153154.GA5750@redhat.com>
 <20190507163520.GA1131@sultan-box.localdomain>
 <20190509155646.GB24526@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190509155646.GB24526@redhat.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 09, 2019 at 05:56:46PM +0200, Oleg Nesterov wrote:
> Impossible ;) I bet lockdep should report the deadlock as soon as find_victims()
> calls find_lock_task_mm() when you already have a locked victim.

I hope you're not a betting man ;)

With the following configured:
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_SPINLOCK=y
# CONFIG_DEBUG_SPINLOCK_BITE_ON_BUG is not set
CONFIG_DEBUG_SPINLOCK_PANIC_ON_BUG=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_WW_MUTEX_SLOWPATH=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
CONFIG_DEBUG_LOCKDEP=y
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
# CONFIG_LOCK_TORTURE_TEST is not set

And a printk added in vtsk_is_duplicate() to print when a duplicate is detected,
and my phone's memory cut in half to make simple_lmk do something, this is what
I observed:
taimen:/ # dmesg | grep lockdep
[    0.000000] \x09RCU lockdep checking is enabled.
taimen:/ # dmesg | grep simple_lmk
[   23.211091] simple_lmk: Killing android.carrier with adj 906 to free 37420 kiB
[   23.211160] simple_lmk: Killing oadcastreceiver with adj 906 to free 36784 kiB
[   23.248457] simple_lmk: Killing .apps.translate with adj 904 to free 45884 kiB
[   23.248720] simple_lmk: Killing ndroid.settings with adj 904 to free 42868 kiB
[   23.313417] simple_lmk: DUPLICATE VTSK!
[   23.313440] simple_lmk: Killing ndroid.keychain with adj 906 to free 33680 kiB
[   23.313513] simple_lmk: Killing com.whatsapp with adj 904 to free 51436 kiB
[   34.646695] simple_lmk: DUPLICATE VTSK!
[   34.646717] simple_lmk: Killing ndroid.apps.gcs with adj 906 to free 37956 kiB
[   34.646792] simple_lmk: Killing droid.apps.maps with adj 904 to free 63600 kiB
taimen:/ # dmesg | grep lockdep
[    0.000000] \x09RCU lockdep checking is enabled.
taimen:/ # 

> As for https://github.com/kerneltoast/android_kernel_google_wahoo/commit/afc8c9bf2dbde95941253c168d1adb64cfa2e3ad
> Well,
> 
> 	mmdrop(mm);
> 	simple_lmk_mm_freed(mm);
> 
> looks racy because mmdrop(mm) can free this mm_struct. Yes, simple_lmk_mm_freed()
> does not dereference this pointer, but the same memory can be re-allocated as
> another ->mm for the new task which can be found by find_victims(), and _in theory_
> this all can happen in between, so the "victims[i].mm == mm" can be false positive.
> 
> And this also means that simple_lmk_mm_freed() should clear victims[i].mm when
> it detects "victims[i].mm == mm", otherwise we have the same theoretical race,
> victims_to_kill is only cleared when the last victim goes away.

Fair point. Putting simple_lmk_mm_freed(mm) right before mmdrop(mm), and
sprinkling in a cmpxchg in simple_lmk_mm_freed() should fix that up.

> Another nit... you can drop tasklist_lock right after the 1st "find_victims" loop.

True!

> And it seems that you do not really need to walk the "victims" array twice after that,
> you can do everything in a single loop, but this is cosmetic.

Won't this result in potentially holding the task lock way longer than necessary
for multiple tasks that aren't going to be killed?

Thanks,
Sultan


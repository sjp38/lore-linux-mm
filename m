Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CB08C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 17:45:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B64A2087C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 17:45:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B64A2087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kerneltoast.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 88C2D8E0003; Tue, 12 Mar 2019 13:45:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 811988E0002; Tue, 12 Mar 2019 13:45:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D98D8E0003; Tue, 12 Mar 2019 13:45:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 33DB58E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 13:45:28 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id x133so1478646oia.3
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 10:45:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=HccK+fYLtqpEZfMwiBe6D8C3e7wDwbf9WW50Z/PProI=;
        b=k5CwnV6HkqxQ9gdT8RmpI7tLzrJ6UvLI6+MA6QX54Xg0G6+ksbzTRAn7F26a5Kkt9z
         CiDBXM9vP15/imewN9q+qElMGGX7Pz1hA4SoKOKt4gXlSraggVO4Prae37bVrK5KEJtB
         LNiNNr2m+VkHO84sWgd8W2MDgVdRPycWZ9UQ5IkbVW4GPtnVAIMQ9ZUc3I+5hDpWQjKU
         Ov8SEt9aK/DZwbiO3Fm6IX9IxWPJPlG+NvrtLEEWAB4DN3Kvdl7i3Hb6EQk0m0iqGjfR
         E9xnhB9JvS8hGqMZVI+7QYmRZV5OJplrPvB5el64MKMYYQBeOeMHim8GpdQFx51VVEli
         xB8A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Gm-Message-State: APjAAAWoixYR34ivnDpOBw0jkjq594x1QRTKOvMR69mmpALPqD39acwk
	VHfsBp9lHyXrRgPkDRo+vlTvuAAlFj7iTBTQQkrFfw5QLl9F4yXKJ+qR0XHkNgHPwzawYlqndzQ
	aJy1SBBXc+yVKc3GPI8/jV9OV3ZQaQiUNmWRnPMUO5HUSjseW1UMdCWxt8GLLXw1ZtjjNy2MDIf
	iV7GjOQQdCkO42HqWjpV21rfBgca5tMtjaFUqBY6PiI5wUSuKIQAAr1TrjgtxZGWkFnw0LHDocA
	z+FG1ddtT9UBXm3W9DyTL1MNdtTu2rbW25aI+BKaKI0xtUu4AqIrvM6VZQat7G8ZiqylY3iLH2d
	UQzVSkZ/nr/G2jznwU/iMd8/xxe+F4b9hCVzLuBM+aqcmKw1Emt92Zo76nQmsLJVU9Gc3bMtAQ=
	=
X-Received: by 2002:a05:6830:20d7:: with SMTP id z23mr25261892otq.178.1552412727917;
        Tue, 12 Mar 2019 10:45:27 -0700 (PDT)
X-Received: by 2002:a05:6830:20d7:: with SMTP id z23mr25261807otq.178.1552412726452;
        Tue, 12 Mar 2019 10:45:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552412726; cv=none;
        d=google.com; s=arc-20160816;
        b=Aq96NhRhez2CFVyPBl8wHsdMCpq5FhuuLozt0wjBmzspVZacbkOKVySdEsyn3cNjQM
         +ADdW53J6eEfdTgv3uZNFg43X6q/NbIAfU85kK/mku54UqgzwHmrbsFZuSsBp0iYrt7B
         OpvQX/HmtSCvBmgKv3vq9kDnwLG66itkc20iwG7FtcfglJfpbNwrpgONb67HemBltY6I
         q+RMGWfaE4vDv2duZkwjywikPD+8f47TNNKQKx812/prenS0Yk22JSA7YDsAkFhGnzov
         iywy4xx4mxO1hW3lEWlp+1k5lNPCBzXoQbSrYdpC2Nlnfph2izY0vvWiv0xORjwPDcln
         QmSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=HccK+fYLtqpEZfMwiBe6D8C3e7wDwbf9WW50Z/PProI=;
        b=Lk/tLoMeVv4uZj/jB7kmdCXOVwsXX5FXgq795C8oiJr59YLr2OjQzvio0Tz+vQ8xtG
         sh6rTKBVBF7YBcvgPIwrzUsJhN/CTKxoHbI/Xr7xadgNmllRX4kpx2a/OemrlICaBoIm
         HkRANPNaUhhd6khMhJMxa10al41sR8W2NpKTNiFE8gUtJ0H6ssYVaTpHFv+Og4pPpKvK
         /TNUEQEg/pdLVI7OcwP9QcSAvhtr55YaCOo3moNHem0cJQTVap9W8zGOpoSDTdW4l3bM
         pu1ij2GfG2/kI3G9tVeKeCgy9aa0thvkbBlJsV4kntFNhuYjo83QcEj/tHcyO+2SxIdL
         hEVA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u81sor4856104oie.88.2019.03.12.10.45.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 10:45:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sultan.kerneltoast@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=sultan.kerneltoast@gmail.com
X-Google-Smtp-Source: APXvYqye0hnmv7pAGXdBIolazCUN2OVPVRFmxBCKF9wVuEGFBFrjN4yDlavLRNISW9yrF7O+Mdtchg==
X-Received: by 2002:aca:6cc9:: with SMTP id h192mr2487951oic.161.1552412726061;
        Tue, 12 Mar 2019 10:45:26 -0700 (PDT)
Received: from sultan-box.localdomain ([107.193.118.89])
        by smtp.gmail.com with ESMTPSA id x3sm3536175otg.52.2019.03.12.10.45.24
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Mar 2019 10:45:25 -0700 (PDT)
Date: Tue, 12 Mar 2019 10:45:20 -0700
From: Sultan Alsawaf <sultan@kerneltoast.com>
To: Tim Murray <timmurray@google.com>
Cc: Michal Hocko <mhocko@kernel.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Christian Brauner <christian@brauner.io>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, devel@driverdev.osuosl.org,
	linux-mm <linux-mm@kvack.org>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190312174520.GA9276@sultan-box.localdomain>
References: <20190310203403.27915-1-sultan@kerneltoast.com>
 <20190311174320.GC5721@dhcp22.suse.cz>
 <20190311175800.GA5522@sultan-box.localdomain>
 <CAJuCfpHTjXejo+u--3MLZZj7kWQVbptyya4yp1GLE3hB=BBX7w@mail.gmail.com>
 <20190311204626.GA3119@sultan-box.localdomain>
 <CAJuCfpGpBxofTT-ANEEY+dFCSdwkQswox3s8Uk9Eq0BnK9i0iA@mail.gmail.com>
 <20190312080532.GE5721@dhcp22.suse.cz>
 <20190312163741.GA2762@sultan-box.localdomain>
 <CAEe=Sxn_uayj48wo7oqf8mNZ7QAGJUQVmkPcHcuEGjA_Z8ELeQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAEe=Sxn_uayj48wo7oqf8mNZ7QAGJUQVmkPcHcuEGjA_Z8ELeQ@mail.gmail.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 10:17:43AM -0700, Tim Murray wrote:
> Knowing whether a SIGKILL'd process has finished reclaiming is as far
> as I know not possible without something like procfds. That's where
> the 100ms timeout in lmkd comes in. lowmemorykiller and lmkd both
> attempt to wait up to 100ms for reclaim to finish by checking for the
> continued existence of the thread that received the SIGKILL, but this
> really means that they wait up to 100ms for the _thread_ to finish,
> which doesn't tell you anything about the memory used by that process.
> If those threads terminate early and lowmemorykiller/lmkd get a signal
> to kill again, then there may be two processes competing for CPU time
> to reclaim memory. That doesn't reclaim any faster and may be an
> unnecessary kill.
> ...
> - offer a way to wait for process termination so lmkd can tell when
> reclaim has finished and know when killing another process is
> appropriate

Should be pretty easy with something like this:
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 1549584a1..6ac478af2 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1199,6 +1199,7 @@ struct task_struct {
 	unsigned long			lowest_stack;
 	unsigned long			prev_lowest_stack;
 #endif
+	ktime_t sigkill_time;
 
 	/*
 	 * New fields for task_struct should be added above here, so that
diff --git a/kernel/fork.c b/kernel/fork.c
index 9dcd18aa2..0ae182777 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -435,6 +435,8 @@ void put_task_stack(struct task_struct *tsk)
 
 void free_task(struct task_struct *tsk)
 {
+	ktime_t sigkill_time = tsk->sigkill_time;
+	pid_t pid = tsk->pid;
 #ifndef CONFIG_THREAD_INFO_IN_TASK
 	/*
 	 * The task is finally done with both the stack and thread_info,
@@ -455,6 +457,9 @@ void free_task(struct task_struct *tsk)
 	if (tsk->flags & PF_KTHREAD)
 		free_kthread_struct(tsk);
 	free_task_struct(tsk);
+	if (sigkill_time)
+		printk("%d killed after %lld us\n", pid,
+		       ktime_us_delta(ktime_get(), sigkill_time));
 }
 EXPORT_SYMBOL(free_task);
 
@@ -1881,6 +1886,7 @@ static __latent_entropy struct task_struct *copy_process(
 	p->sequential_io	= 0;
 	p->sequential_io_avg	= 0;
 #endif
+	p->sigkill_time = 0;
 
 	/* Perform scheduler related setup. Assign this task to a CPU. */
 	retval = sched_fork(clone_flags, p);
diff --git a/kernel/signal.c b/kernel/signal.c
index 5d53183e2..1142c8811 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -1168,6 +1168,8 @@ static int __send_signal(int sig, struct kernel_siginfo *info, struct task_struc
 	}
 
 out_set:
+	if (sig == SIGKILL)
+		t->sigkill_time = ktime_get();
 	signalfd_notify(t, sig);
 	sigaddset(&pending->signal, sig);


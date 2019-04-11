Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A779AC10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 10:34:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48E062075B
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 10:34:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=brauner.io header.i=@brauner.io header.b="WR7cmCux"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48E062075B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=brauner.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C7C876B0271; Thu, 11 Apr 2019 06:34:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C2DFF6B0272; Thu, 11 Apr 2019 06:34:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B19376B0273; Thu, 11 Apr 2019 06:34:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6055A6B0271
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 06:34:12 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id p90so2843586edp.11
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 03:34:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=SLtwlQnsi2lxcF6BSEB1RE69e3LNi43QlxoMz0lcnyM=;
        b=JWrbS+3cwNfoSKAxEEVzmev8SfdLyQskmeof9Uz39lXMmWVAqwWK2Kr1DjXwVBsp9y
         fCIraVAXVU0H72l7tj9xjm1UJPBkXrLuZ7EHwSppYbxYZAqRzY3qEUsvab4DRXjb8Vsu
         pY9dI/DiPG4P6V/RQyx9jhH3Uess9HMyq3SoF60Z2HQRw57LGxzmle10FS1Mu88bKh4V
         nLSIJwo2Y0E4AlsiDBldfU+b3k7fYwhR18OMvCGLADyp1Q5Dv+j0P2ilozNTHrWpBXRW
         coZUIrIYUk1NmFexMubg55swzJSRMcLmGW8NDH59dwIzL0eSAn8ZpMvzFdm8S21x6Vdt
         kqjw==
X-Gm-Message-State: APjAAAUmDkckKYdU5lNLdD0WEAX4tdglitHBfaWdSKyy4Q7kccI8Kykg
	tK8V1Kk95FEimcHS1aeRFL/eJB5DF75vihOnAsHjoarBBozvziSWxvXcv+TAKKshFeM4zKj+Ei1
	V2Y9ETTj/hdNjBBye6C5h69pk6BxIF3VVGvYHtmBBgV7sN9bbp0KpuGdbEZJJxtqG/Q==
X-Received: by 2002:a05:6402:688:: with SMTP id f8mr31324893edy.189.1554978851933;
        Thu, 11 Apr 2019 03:34:11 -0700 (PDT)
X-Received: by 2002:a05:6402:688:: with SMTP id f8mr31324845edy.189.1554978850982;
        Thu, 11 Apr 2019 03:34:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554978850; cv=none;
        d=google.com; s=arc-20160816;
        b=TJV6FaJrcqaPB3dfYpzk8M+ukxyHJ5PfU79hQqYUz6eUdhFoBlxitpWNRR2d10sOk8
         7PK5amx5KulCKflKa0T5hA+TpuaScUhO8H1kjArA0Yk2EP2uUpt8rDmCvdmliWb7Z0GI
         TmrSC24bypsjtXdSYzOri3UDYZVTmnxTp7d3wSMykul4fY/qXKrBM/Mz+HUpWV5H/bF2
         07LBLTqlEM69YbVusoFfaZVuhxHbCF7s7gi7jrUX6zRCRGp+MWtc1A3skE8LygEETZMk
         FFShDsqKDtFoM33vGfRBsu9sj10CM+Q3wTm6P1KsJxHyquoWO0QpFs9oZY9jmUBVZAV6
         Yl0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=SLtwlQnsi2lxcF6BSEB1RE69e3LNi43QlxoMz0lcnyM=;
        b=ILzFPu8IE0YJ9ZvQAMBtd931S8ghT62gCajwknTcgJMHtAjH/nOXUpXw8/2nlGmFvl
         5JKWwiR+2I61YfaTmfLDW9LUFSiBgzwxzyzoYC+GCUZkjawFmUEQzNU0mHr1b6KqCoJ+
         dzI8TAFGrwoQKQpWxjdiuCu2yiKLev9EodxFNOwcl5WntVa5QtxjGi04L9f0JYLoy4K+
         ltr1ZDYA+ea5J2LHZItmfrH5v5wtNpYr6xq9SApgcTo6oxZBuzaFz2FdbZmz/t6nlEmP
         88F8OT6vGlXpk71Z/y2EfUGVbC5A+hat+uuBAf19O/C77H/5xMT+QXYbt+u4ge2ufYrB
         09gA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=WR7cmCux;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h61sor7011555edc.28.2019.04.11.03.34.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 03:34:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=WR7cmCux;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=brauner.io; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=SLtwlQnsi2lxcF6BSEB1RE69e3LNi43QlxoMz0lcnyM=;
        b=WR7cmCuxaqUTW3U8NCvm3nHG1pEljHfaby69xQf7Yzpfr6r72pl0gd7FUC5bNIXWAr
         Lkb52vpBxGi0q0E1vCBrHjrwd97EqS3DUUqpzYX3P/fFCqsbyl/imgNs+VHbiNkdlslg
         V/yywiCR4LWDNPIuTrXdE8hnXTBn7GT0EmZM4tQsZTT5Htt2rw78Mqwezbw3etngp1MB
         V4xleOURfQF2S0QRBXQBFmYMFxfQ1UYskDWKPyBqZ77tE6a9UxiSIgFtqBO0s/m8mQ7N
         B62XNWDenkl0iaEFES/inbg7cx7fFzOJpE3EMU+KmZHAMuWksB7YDB7I9UwQ1/niTvEf
         eNUA==
X-Google-Smtp-Source: APXvYqwA6LgvLM60i09zDdeKKwXX937omKO+V0ZH1k2dUoOGwbesknRoF0Nc2lHHpaDhrf2UXCInCg==
X-Received: by 2002:a50:93a6:: with SMTP id o35mr31398796eda.245.1554978850611;
        Thu, 11 Apr 2019 03:34:10 -0700 (PDT)
Received: from brauner.io ([212.91.227.56])
        by smtp.gmail.com with ESMTPSA id h16sm2378946edq.73.2019.04.11.03.34.09
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 11 Apr 2019 03:34:10 -0700 (PDT)
Date: Thu, 11 Apr 2019 12:34:08 +0200
From: Christian Brauner <christian@brauner.io>
To: Suren Baghdasaryan <surenb@google.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, rientjes@google.com,
	willy@infradead.org, yuzhoujian@didichuxing.com,
	jrdr.linux@gmail.com, guro@fb.com, hannes@cmpxchg.org,
	penguin-kernel@I-love.SAKURA.ne.jp, ebiederm@xmission.com,
	shakeelb@google.com, minchan@kernel.org, timmurray@google.com,
	dancol@google.com, joel@joelfernandes.org, jannh@google.com,
	linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kernel-team@android.com,
	oleg@redhat.com
Subject: Re: [RFC 2/2] signal: extend pidfd_send_signal() to allow expedited
 process killing
Message-ID: <20190411103407.67zdy5zzp7lsyaa4@brauner.io>
References: <20190411014353.113252-1-surenb@google.com>
 <20190411014353.113252-3-surenb@google.com>
 <20190411103018.tcsinifuj7klh6rp@brauner.io>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190411103018.tcsinifuj7klh6rp@brauner.io>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Cc: Oleg too

On Thu, Apr 11, 2019 at 12:30:18PM +0200, Christian Brauner wrote:
> On Wed, Apr 10, 2019 at 06:43:53PM -0700, Suren Baghdasaryan wrote:
> > Add new SS_EXPEDITE flag to be used when sending SIGKILL via
> > pidfd_send_signal() syscall to allow expedited memory reclaim of the
> > victim process. The usage of this flag is currently limited to SIGKILL
> > signal and only to privileged users.
> > 
> > Signed-off-by: Suren Baghdasaryan <surenb@google.com>
> > ---
> >  include/linux/sched/signal.h |  3 ++-
> >  include/linux/signal.h       | 11 ++++++++++-
> >  ipc/mqueue.c                 |  2 +-
> >  kernel/signal.c              | 37 ++++++++++++++++++++++++++++--------
> >  kernel/time/itimer.c         |  2 +-
> >  5 files changed, 43 insertions(+), 12 deletions(-)
> > 
> > diff --git a/include/linux/sched/signal.h b/include/linux/sched/signal.h
> > index e412c092c1e8..8a227633a058 100644
> > --- a/include/linux/sched/signal.h
> > +++ b/include/linux/sched/signal.h
> > @@ -327,7 +327,8 @@ extern int send_sig_info(int, struct kernel_siginfo *, struct task_struct *);
> >  extern void force_sigsegv(int sig, struct task_struct *p);
> >  extern int force_sig_info(int, struct kernel_siginfo *, struct task_struct *);
> >  extern int __kill_pgrp_info(int sig, struct kernel_siginfo *info, struct pid *pgrp);
> > -extern int kill_pid_info(int sig, struct kernel_siginfo *info, struct pid *pid);
> > +extern int kill_pid_info(int sig, struct kernel_siginfo *info, struct pid *pid,
> > +				bool expedite);
> >  extern int kill_pid_info_as_cred(int, struct kernel_siginfo *, struct pid *,
> >  				const struct cred *);
> >  extern int kill_pgrp(struct pid *pid, int sig, int priv);
> > diff --git a/include/linux/signal.h b/include/linux/signal.h
> > index 9702016734b1..34b7852aa4a0 100644
> > --- a/include/linux/signal.h
> > +++ b/include/linux/signal.h
> > @@ -446,8 +446,17 @@ int __save_altstack(stack_t __user *, unsigned long);
> >  } while (0);
> >  
> >  #ifdef CONFIG_PROC_FS
> > +
> > +/*
> > + * SS_FLAGS values used in pidfd_send_signal:
> > + *
> > + * SS_EXPEDITE indicates desire to expedite the operation.
> > + */
> > +#define SS_EXPEDITE	0x00000001
> 
> Does this make sense as an SS_* flag?
> How does this relate to the signal stack?
> Is there any intention to ever use this flag with stack_t?
> 
> New flags should be PIDFD_SIGNAL_*. (E.g. the thread flag will be
> PIDFD_SIGNAL_THREAD.)
> And since this is exposed to userspace in contrast to the mm internal
> naming it should be something more easily understandable like
> PIDFD_SIGNAL_MM_RECLAIM{_FASTER} or something.
> 
> > +
> >  struct seq_file;
> >  extern void render_sigset_t(struct seq_file *, const char *, sigset_t *);
> > -#endif
> > +
> > +#endif /* CONFIG_PROC_FS */
> >  
> >  #endif /* _LINUX_SIGNAL_H */
> > diff --git a/ipc/mqueue.c b/ipc/mqueue.c
> > index aea30530c472..27c66296e08e 100644
> > --- a/ipc/mqueue.c
> > +++ b/ipc/mqueue.c
> > @@ -720,7 +720,7 @@ static void __do_notify(struct mqueue_inode_info *info)
> >  			rcu_read_unlock();
> >  
> >  			kill_pid_info(info->notify.sigev_signo,
> > -				      &sig_i, info->notify_owner);
> > +				      &sig_i, info->notify_owner, false);
> >  			break;
> >  		case SIGEV_THREAD:
> >  			set_cookie(info->notify_cookie, NOTIFY_WOKENUP);
> > diff --git a/kernel/signal.c b/kernel/signal.c
> > index f98448cf2def..02ed4332d17c 100644
> > --- a/kernel/signal.c
> > +++ b/kernel/signal.c
> > @@ -43,6 +43,7 @@
> >  #include <linux/compiler.h>
> >  #include <linux/posix-timers.h>
> >  #include <linux/livepatch.h>
> > +#include <linux/oom.h>
> >  
> >  #define CREATE_TRACE_POINTS
> >  #include <trace/events/signal.h>
> > @@ -1394,7 +1395,8 @@ int __kill_pgrp_info(int sig, struct kernel_siginfo *info, struct pid *pgrp)
> >  	return success ? 0 : retval;
> >  }
> >  
> > -int kill_pid_info(int sig, struct kernel_siginfo *info, struct pid *pid)
> > +int kill_pid_info(int sig, struct kernel_siginfo *info, struct pid *pid,
> > +				  bool expedite)
> >  {
> >  	int error = -ESRCH;
> >  	struct task_struct *p;
> > @@ -1402,8 +1404,17 @@ int kill_pid_info(int sig, struct kernel_siginfo *info, struct pid *pid)
> >  	for (;;) {
> >  		rcu_read_lock();
> >  		p = pid_task(pid, PIDTYPE_PID);
> > -		if (p)
> > +		if (p) {
> >  			error = group_send_sig_info(sig, info, p, PIDTYPE_TGID);
> > +
> > +			/*
> > +			 * Ignore expedite_reclaim return value, it is best
> > +			 * effort only.
> > +			 */
> > +			if (!error && expedite)
> > +				expedite_reclaim(p);
> 
> SIGKILL will take the whole thread group down so the reclaim should make
> sense here.
> 
> > +		}
> > +
> >  		rcu_read_unlock();
> >  		if (likely(!p || error != -ESRCH))
> >  			return error;
> > @@ -1420,7 +1431,7 @@ static int kill_proc_info(int sig, struct kernel_siginfo *info, pid_t pid)
> >  {
> >  	int error;
> >  	rcu_read_lock();
> > -	error = kill_pid_info(sig, info, find_vpid(pid));
> > +	error = kill_pid_info(sig, info, find_vpid(pid), false);
> >  	rcu_read_unlock();
> >  	return error;
> >  }
> > @@ -1487,7 +1498,7 @@ static int kill_something_info(int sig, struct kernel_siginfo *info, pid_t pid)
> >  
> >  	if (pid > 0) {
> >  		rcu_read_lock();
> > -		ret = kill_pid_info(sig, info, find_vpid(pid));
> > +		ret = kill_pid_info(sig, info, find_vpid(pid), false);
> >  		rcu_read_unlock();
> >  		return ret;
> >  	}
> > @@ -1704,7 +1715,7 @@ EXPORT_SYMBOL(kill_pgrp);
> >  
> >  int kill_pid(struct pid *pid, int sig, int priv)
> >  {
> > -	return kill_pid_info(sig, __si_special(priv), pid);
> > +	return kill_pid_info(sig, __si_special(priv), pid, false);
> >  }
> >  EXPORT_SYMBOL(kill_pid);
> >  
> > @@ -3577,10 +3588,20 @@ SYSCALL_DEFINE4(pidfd_send_signal, int, pidfd, int, sig,
> >  	struct pid *pid;
> >  	kernel_siginfo_t kinfo;
> >  
> > -	/* Enforce flags be set to 0 until we add an extension. */
> > -	if (flags)
> > +	/* Enforce no unknown flags. */
> > +	if (flags & ~SS_EXPEDITE)
> >  		return -EINVAL;
> >  
> > +	if (flags & SS_EXPEDITE) {
> > +		/* Enforce SS_EXPEDITE to be used with SIGKILL only. */
> > +		if (sig != SIGKILL)
> > +			return -EINVAL;
> 
> Not super fond of this being a SIGKILL specific flag but I get why.
> 
> > +
> > +		/* Limit expedited killing to privileged users only. */
> > +		if (!capable(CAP_SYS_NICE))
> > +			return -EPERM;
> 
> Do you have a specific (DOS or other) attack vector in mind that renders
> ns_capable unsuitable?
> 
> > +	}
> > +
> >  	f = fdget_raw(pidfd);
> >  	if (!f.file)
> >  		return -EBADF;
> > @@ -3614,7 +3635,7 @@ SYSCALL_DEFINE4(pidfd_send_signal, int, pidfd, int, sig,
> >  		prepare_kill_siginfo(sig, &kinfo);
> >  	}
> >  
> > -	ret = kill_pid_info(sig, &kinfo, pid);
> > +	ret = kill_pid_info(sig, &kinfo, pid, (flags & SS_EXPEDITE) != 0);
> >  
> >  err:
> >  	fdput(f);
> > diff --git a/kernel/time/itimer.c b/kernel/time/itimer.c
> > index 02068b2d5862..c926483cdb53 100644
> > --- a/kernel/time/itimer.c
> > +++ b/kernel/time/itimer.c
> > @@ -140,7 +140,7 @@ enum hrtimer_restart it_real_fn(struct hrtimer *timer)
> >  	struct pid *leader_pid = sig->pids[PIDTYPE_TGID];
> >  
> >  	trace_itimer_expire(ITIMER_REAL, leader_pid, 0);
> > -	kill_pid_info(SIGALRM, SEND_SIG_PRIV, leader_pid);
> > +	kill_pid_info(SIGALRM, SEND_SIG_PRIV, leader_pid, false);
> >  
> >  	return HRTIMER_NORESTART;
> >  }
> > -- 
> > 2.21.0.392.gf8f6787159e-goog
> > 


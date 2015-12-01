Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0DEE56B0253
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 18:48:24 -0500 (EST)
Received: by wmvv187 with SMTP id v187so231002155wmv.1
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 15:48:23 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q189si1146033wmd.74.2015.12.01.15.48.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 15:48:23 -0800 (PST)
Date: Tue, 1 Dec 2015 15:48:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/5] dump_stack: allow specifying printk log level
Message-Id: <20151201154820.abd9f2aba7a973daf29d2527@linux-foundation.org>
In-Reply-To: <20151109162125.GI8916@dhcp22.suse.cz>
References: <20151105223014.701269769@redhat.com>
	<20151109162125.GI8916@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: aris@redhat.com, linux-kerne@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>

On Mon, 9 Nov 2015 17:21:25 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> > This patchset introduces two new functions:
> > 	dump_stack_lvl(char *log_lvl)
> > 	show_stack_lvl(struct task_struct *task, unsigned long *sp, char *log_lvl)
> > 
> > and both can be reimplemented by each architecture but only the second is
> > expected. The idea is to initially implement show_stack_lvl() in all
> > architectures then simply have show_stack() to require log_lvl as parameter.
> > While that happens, dump_stack() uses can be changed to dump_stack_lvl() and
> > once everything is in place, dump_stack() will require the log_level as well.
> 
> This looks good to me FWIW.

Seems reasonable to me as well and yes, there will be extra fill-in
work to do.

The "lvl" thing stands out - kernel code doesn't do this arbitrary
vowelicide to make identifiers shorter.  s/lvl/level/g?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

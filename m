Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 683DE6B00D9
	for <linux-mm@kvack.org>; Sun, 27 Oct 2013 09:00:44 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id uo5so3213619pbc.23
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 06:00:44 -0700 (PDT)
Received: from psmtp.com ([74.125.245.184])
        by mx.google.com with SMTP id yk3si10369587pac.99.2013.10.27.06.00.42
        for <linux-mm@kvack.org>;
        Sun, 27 Oct 2013 06:00:43 -0700 (PDT)
Received: by mail-qe0-f41.google.com with SMTP id x7so3460009qeu.28
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 06:00:41 -0700 (PDT)
Date: Sun, 27 Oct 2013 09:00:36 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/3] percpu counter: cast this_cpu_sub() adjustment
Message-ID: <20131027130036.GN14934@mtj.dyndns.org>
References: <1382859876-28196-1-git-send-email-gthelen@google.com>
 <1382859876-28196-3-git-send-email-gthelen@google.com>
 <20131027112255.GB14934@mtj.dyndns.org>
 <20131027050429.7fcc2ed5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131027050429.7fcc2ed5.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, handai.szj@taobao.com, x86@kernel.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

On Sun, Oct 27, 2013 at 05:04:29AM -0700, Andrew Morton wrote:
> On Sun, 27 Oct 2013 07:22:55 -0400 Tejun Heo <tj@kernel.org> wrote:
> 
> > We probably want to cc stable for this and the next one.  How should
> > these be routed?  I can take these through percpu tree or mm works
> > too.  Either way, it'd be best to route them together.
> 
> Yes, all three look like -stable material to me.  I'll grab them later
> in the week if you haven't ;)

Tried to apply to percpu but the third one is a fix for a patch which
was added to -mm during v3.12-rc1, so these are yours. :)

> The names of the first two patches distress me.  They rather clearly
> assert that the code affects percpu_counter.[ch], but that is not the case. 
> Massaging is needed to fix that up.

Yeah, something like the following would be better

 percpu: add test module for various percpu operations
 percpu: fix this_cpu_sub() subtrahend casting for unsigneds
 memcg: use __this_cpu_sub() to dec stats to avoid incorrect subtrahend casting

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 18E136B00DC
	for <linux-mm@kvack.org>; Sun, 27 Oct 2013 08:03:38 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id q10so5896429pdj.0
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 05:03:37 -0700 (PDT)
Received: from psmtp.com ([74.125.245.145])
        by mx.google.com with SMTP id dk5si9317136pbc.106.2013.10.27.05.03.36
        for <linux-mm@kvack.org>;
        Sun, 27 Oct 2013 05:03:36 -0700 (PDT)
Date: Sun, 27 Oct 2013 05:04:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3] percpu counter: cast this_cpu_sub() adjustment
Message-Id: <20131027050429.7fcc2ed5.akpm@linux-foundation.org>
In-Reply-To: <20131027112255.GB14934@mtj.dyndns.org>
References: <1382859876-28196-1-git-send-email-gthelen@google.com>
	<1382859876-28196-3-git-send-email-gthelen@google.com>
	<20131027112255.GB14934@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, handai.szj@taobao.com, x86@kernel.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

On Sun, 27 Oct 2013 07:22:55 -0400 Tejun Heo <tj@kernel.org> wrote:

> We probably want to cc stable for this and the next one.  How should
> these be routed?  I can take these through percpu tree or mm works
> too.  Either way, it'd be best to route them together.

Yes, all three look like -stable material to me.  I'll grab them later
in the week if you haven't ;)

The names of the first two patches distress me.  They rather clearly
assert that the code affects percpu_counter.[ch], but that is not the case. 
Massaging is needed to fix that up.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

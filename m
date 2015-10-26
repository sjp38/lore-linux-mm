Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 7CB5D82F64
	for <linux-mm@kvack.org>; Mon, 26 Oct 2015 13:40:51 -0400 (EDT)
Received: by qkbl190 with SMTP id l190so112045835qkb.2
        for <linux-mm@kvack.org>; Mon, 26 Oct 2015 10:40:51 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f92si32939115qge.78.2015.10.26.10.40.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Oct 2015 10:40:50 -0700 (PDT)
Date: Mon, 26 Oct 2015 13:40:49 -0400
From: Aristeu Rozanski <arozansk@redhat.com>
Subject: Re: [PATCH] oom_kill: add option to disable dump_stack()
Message-ID: <20151026174048.GP15046@redhat.com>
References: <1445634150-27992-1-git-send-email-arozansk@redhat.com>
 <20151026172012.GC9779@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151026172012.GC9779@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, cgroups@vger.kernel.org

Hi Michal,
On Mon, Oct 26, 2015 at 06:20:12PM +0100, Michal Hocko wrote:
> I can see why you want to reduce the amount of information, I guess you
> have tried to reduce the loglevel but this hasn't helped because
> dump_stack uses default log level which is too low to be usable, right?
> Or are there any other reasons?

One would be that the stack trace isn't very useful for users IMHO.

> I am not sure sysctl is a good way to tell this particular restriction
> on the output. What if somebody else doesn't want to see the list of
> eligible tasks? Should we add another knob?
>
> Would it make more sense to distinguish different parts of the OOM
> report by loglevel properly?
> pr_err - killed task report
> pr_warning - oom invocation + memory info
> pr_notice - task list
> pr_info - stack trace

That'd work, yes, but I'd think the stack trace would be pr_debug. At a
point that you suspect the OOM killer isn't doing the right thing picking
up tasks and you need more information.

-- 
Aristeu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

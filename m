Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id EC6BA800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 20:54:50 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id h17so3108637wmc.6
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 17:54:50 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id s7si2876311wrc.349.2018.01.24.17.54.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 17:54:49 -0800 (PST)
Date: Thu, 25 Jan 2018 01:54:41 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v2] fs: fsnotify: account fsnotify metadata to kmemcg
Message-ID: <20180125015441.GS13338@ZenIV.linux.org.uk>
References: <20171109135444.znaksm4fucmpuylf@dhcp22.suse.cz>
 <10924085-6275-125f-d56b-547d734b6f4e@alibaba-inc.com>
 <20171114093909.dbhlm26qnrrb2ww4@dhcp22.suse.cz>
 <afa2dc80-16a3-d3d1-5090-9430eaafc841@alibaba-inc.com>
 <20171115093131.GA17359@quack2.suse.cz>
 <CALvZod6HJO73GUfLemuAXJfr4vZ8xMOmVQpFO3vJRog-s2T-OQ@mail.gmail.com>
 <CAOQ4uxg-mTgQfTv-qO6EVwfttyOy+oFyAHyFDKTQsDOkQPyyfA@mail.gmail.com>
 <20180124103454.ibuqt3njaqbjnrfr@quack2.suse.cz>
 <CAOQ4uxhDpBBUrr0JWRBaNQTTaUeJ4=gnM0iij2KivaGgp1ggtg@mail.gmail.com>
 <CALvZod4PyqfaqgEswegF5uOjNwVwbY1C4ptJB0Ouvgchv2aVFg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALvZod4PyqfaqgEswegF5uOjNwVwbY1C4ptJB0Ouvgchv2aVFg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Amir Goldstein <amir73il@gmail.com>, Jan Kara <jack@suse.cz>, Yang Shi <yang.s@alibaba-inc.com>, Michal Hocko <mhocko@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jan 24, 2018 at 05:08:27PM -0800, Shakeel Butt wrote:
> First, let me apologize, I think I might have led the discussion in
> wrong direction by giving one wrong information. The current upstream
> kernel, from the syscall context, does not invoke oom-killer when a
> memcg hits its limit and fails to reclaim memory, instead ENOMEM is
> returned. The memcg oom-killer is only invoked on page faults. However
> in a separate effort I do plan to converge the behavior, long
> discussion at <https://patchwork.kernel.org/patch/9988063/>.

Correct me if I'm misinterpreting you, but your rationale in there
appears to be along the lines of "userland applications might not
be ready to handle -ENOMEM gracefully, so let's hit them with
kill -9 instead - that will be handled properly, 'cuz M4G1C!!1!!!!"

I must admit that I like the general feel of that idea; may I suggest,
as a modest improvement, appending "/usr/local/bin/self-LART\n"
to the end of $HOME/.bashrc as well?  Killing luser's processes is
a nice start, but you have to allow for local policies...

-- 
WWSimonDo?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

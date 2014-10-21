Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id CFB9082BDD
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 09:22:48 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id p9so1011476lbv.35
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 06:22:48 -0700 (PDT)
Received: from v094114.home.net.pl (v094114.home.net.pl. [79.96.170.134])
        by mx.google.com with SMTP id qs7si18921690lbb.76.2014.10.21.06.22.35
        for <linux-mm@kvack.org>;
        Tue, 21 Oct 2014 06:22:36 -0700 (PDT)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH 4/4] PM: convert do_each_thread to for_each_process_thread
Date: Tue, 21 Oct 2014 15:43:01 +0200
Message-ID: <3958989.fNI6B5yhny@vostro.rjw.lan>
In-Reply-To: <20141021131953.GD9415@dhcp22.suse.cz>
References: <1413876435-11720-1-git-send-email-mhocko@suse.cz> <2670728.8H9BNSArM8@vostro.rjw.lan> <20141021131953.GD9415@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>

On Tuesday, October 21, 2014 03:19:53 PM Michal Hocko wrote:
> On Tue 21-10-14 14:10:18, Rafael J. Wysocki wrote:
> > On Tuesday, October 21, 2014 09:27:15 AM Michal Hocko wrote:
> > > as per 0c740d0afc3b (introduce for_each_thread() to replace the buggy
> > > while_each_thread()) get rid of do_each_thread { } while_each_thread()
> > > construct and replace it by a more error prone for_each_thread.
> > > 
> > > This patch doesn't introduce any user visible change.
> > > 
> > > Suggested-by: Oleg Nesterov <oleg@redhat.com>
> > > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > 
> > ACK
> > 
> > Or do you want me to handle this series?
> 
> I don't know, I hoped either you or Andrew to pick it up.

OK, I will then.

-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

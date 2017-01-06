Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A0D606B0038
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 05:18:37 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id m203so2762691wma.2
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 02:18:37 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y129si2222468wmd.108.2017.01.06.02.18.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Jan 2017 02:18:36 -0800 (PST)
Date: Fri, 6 Jan 2017 11:18:34 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Bug 190191] New: kswapd0 spirals out of control
Message-ID: <20170106101834.GA5561@dhcp22.suse.cz>
References: <bug-190191-27@https.bugzilla.kernel.org/>
 <20170105114233.b5c80f88f625815eaec70bc1@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170105114233.b5c80f88f625815eaec70bc1@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, dh@kernel.usrbin.org

On Thu 05-01-17 11:42:33, Andrew Morton wrote:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Mon, 12 Dec 2016 19:38:23 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > https://bugzilla.kernel.org/show_bug.cgi?id=190191
> > 
> >             Bug ID: 190191
> >            Summary: kswapd0 spirals out of control
> >            Product: Memory Management
> >            Version: 2.5
> >     Kernel Version: 4.8.0+
> >           Hardware: i386
> >                 OS: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: high
> >           Priority: P1
> >          Component: Other
> >           Assignee: akpm@linux-foundation.org
> >           Reporter: dh@kernel.usrbin.org
> >         Regression: No
> 
> I'd say "Regression: yes".
> 
> Additional details at the link.  There's no indication which commit(s)
> broke it.
> 
> > Created attachment 247481
> >   --> https://bugzilla.kernel.org/attachment.cgi?id=247481&action=edit
> > config for 4.7
> > 
> > I'm currently running 4.7.10 with no problems, but when i tried to upgrade to
> > 4.8.0 (and just now, 4.9.0) i encountered a problem that makes my system
> > unusable.

Considering this is 32b kernel and we know that node reclaim (introduced
in 4.8) is broken with memcg enabled because Normal zone inactive list
might not be aged properly I would suggest trying to run with
http://lkml.kernel.org/r/20170104100825.3729-1-mhocko@kernel.org
applied. It is hard to tell anything more without further information
though.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

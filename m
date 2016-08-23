Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 933846B0038
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 12:03:41 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p85so100126159lfg.3
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 09:03:41 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id m12si3728352wjq.88.2016.08.23.09.03.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 09:03:40 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id i138so18699048wmf.3
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 09:03:40 -0700 (PDT)
Date: Tue, 23 Aug 2016 18:03:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] kernel/fork: fix CLONE_CHILD_CLEARTID regression in
 nscd
Message-ID: <20160823160337.GA25099@dhcp22.suse.cz>
References: <1470039287-14643-1-git-send-email-mhocko@kernel.org>
 <20160803210804.GA11549@redhat.com>
 <20160812094113.GE3639@dhcp22.suse.cz>
 <20160819132511.GH32619@dhcp22.suse.cz>
 <20160823152711.GA4067@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160823152711.GA4067@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, William Preston <wpreston@suse.com>, Roland McGrath <roland@hack.frob.com>, Andreas Schwab <schwab@suse.com>

On Tue 23-08-16 17:27:11, Oleg Nesterov wrote:
> On 08/19, Michal Hocko wrote:
[...]
> > or we do not care about this
> > "regression"
> 
> Honestly, I do not know ;) Personally, I am always scared when it comes
> to the subtle changes like this, you can never know what can be broken.

If _you_ are scarred (after so many years of permanent exposure to this
code) then try to imagine how I am scarred when touching anything in
this area...

> And note that it can be broken 10 years later, like it happened with
> nscd ;)
> 
> But if you send the s/PF_SIGNALED/SIGNAL_GROUP_COREDUMP/ change I will
> ack it ;)

OK, I will repost

> Even if it won't really fix this nscd problem (imo), because
> I guess nscd wants to reset ->clear_child_tid even if the signal was
> sig_kernel_coredump().

Come on, have you ever seen this fine piece of software crashing?
But more seriously, I wouldn't give a damn because nscd is usually the
first thing I disable on my systems but there seem to be people who
would like to use this persistence thingy and even service restart will
break it. So I think we should plug this hole.

Anyway thanks for your review and feedback. As always it is really
appreciated!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

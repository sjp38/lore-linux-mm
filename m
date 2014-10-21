Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id 072306B009A
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 10:29:46 -0400 (EDT)
Received: by mail-la0-f51.google.com with SMTP id ge10so1156682lab.24
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 07:29:46 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x2si19166958lae.118.2014.10.21.07.29.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Oct 2014 07:29:41 -0700 (PDT)
Date: Tue, 21 Oct 2014 16:29:39 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/4] OOM, PM: OOM killed task shouldn't escape PM suspend
Message-ID: <20141021142939.GG9415@dhcp22.suse.cz>
References: <1413876435-11720-1-git-send-email-mhocko@suse.cz>
 <2156351.pWp6MNRoWm@vostro.rjw.lan>
 <20141021141159.GE9415@dhcp22.suse.cz>
 <4766859.KSKPTm3b0x@vostro.rjw.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4766859.KSKPTm3b0x@vostro.rjw.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>

On Tue 21-10-14 16:41:07, Rafael J. Wysocki wrote:
> On Tuesday, October 21, 2014 04:11:59 PM Michal Hocko wrote:
[...]
> > OK, incremental diff on top. I will post the complete patch if you are
> > happier with this change
> 
> Yes, I am.
---

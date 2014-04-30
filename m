Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id A016E6B0039
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 04:36:25 -0400 (EDT)
Received: by mail-ee0-f51.google.com with SMTP id c13so1084103eek.10
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 01:36:24 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q5si29928424eem.141.2014.04.30.01.36.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 30 Apr 2014 01:36:23 -0700 (PDT)
Date: Wed, 30 Apr 2014 10:36:20 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Is heap_stack_gap useless?
Message-ID: <20140430083620.GA4711@dhcp22.suse.cz>
References: <CAG4AFWaemUiR1HTx5dUUQf3V4twuwuiBdtDLNEeEoF-ikTThpQ@mail.gmail.com>
 <CAG4AFWa0MGEZvyqq5VWCpsQGFCGbu-16V_djv_sEW6YV3VDSGw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG4AFWa0MGEZvyqq5VWCpsQGFCGbu-16V_djv_sEW6YV3VDSGw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jidong Xiao <jidong.xiao@gmail.com>
Cc: Kernel development list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue 29-04-14 23:59:09, Jidong Xiao wrote:
> On Tue, Apr 29, 2014 at 11:31 PM, Jidong Xiao <jidong.xiao@gmail.com> wrote:
> > Hi,
> >
> > I noticed this variable, defined in mm/nommu.c,
> >
> > mm/nommu.c:int heap_stack_gap = 0;
> >
> > This variable only shows up once, and never shows up in elsewhere.
> >
> > Can some one tell me is this useless? If so, I will submit a patch to remove
> > it.

Hint: Do not be afraid to do a bit of git research when you want to do
clean-ups like this.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

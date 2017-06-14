Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9E2C26B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 02:30:50 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id w91so36006883wrb.13
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 23:30:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 60si2483548wro.213.2017.06.13.23.30.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 13 Jun 2017 23:30:48 -0700 (PDT)
Date: Wed, 14 Jun 2017 08:30:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RESEND PATCH] base/memory: pass the base_section in
 add_memory_block
Message-ID: <20170614063038.GE6045@dhcp22.suse.cz>
References: <20170614054550.14469-1-richard.weiyang@gmail.com>
 <20170614060558.GA14009@WeideMBP.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170614060558.GA14009@WeideMBP.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 14-06-17 14:05:58, Wei Yang wrote:
> Hi, Michael
> 
> I copied your reply here:
> 
> >[Sorry for a late response]
> >
> >On Wed 07-06-17 16:52:12, Wei Yang wrote:
> >> The second parameter of init_memory_block() is used to calculate the
> >> start_section_nr of this block, which means any section in the same block
> >> would get the same start_section_nr.
> >
> >Could you be more specific what is the problem here?
> >
> 
> There is no problem in this code. I just find a unnecessary calculation and
> remove it in this patch.

This code needs a larger rething rather than here and there small
changes I believe.

> >> This patch passes the base_section to init_memory_block(), so that to
> >> reduce a local variable and a check in every loop.
> >
> >But then you are not handling a memblock which starts with a !present
> >section. The code is quite hairy but I do not see why your change is any
> 
> I don't see the situation you pointed here.
> 
> In add_memory_block(), section_nr is used to record the first section which is
> present. And this variable is used to calculate the section which is passed to
> init_memory_block().
> 
> In init_memory_block(), the section got from add_memory_block(), is used to
> calculate scn_nr, but finally transformed to "start_section_nr". That means in
> init_memory_block(), we just need the "start_section_nr" of a memory_block. We
> don't care about who is the first present section.

You are right. The code is confusing as hell!

That being said, I am not opposing the patch but I would much rather
appreciate a consistent cleanup in the whole memblock vs. sections area.
That would be a larger project but the end result is really worth it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

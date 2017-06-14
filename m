Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id ACBAB6B02F3
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 02:22:17 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g46so4917923wrd.3
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 23:22:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 188si446960wmf.101.2017.06.13.23.22.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 13 Jun 2017 23:22:16 -0700 (PDT)
Date: Wed, 14 Jun 2017 08:22:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RESEND PATCH] base/memory: pass the base_section in
 add_memory_block
Message-ID: <20170614062213.GD6045@dhcp22.suse.cz>
References: <20170614054550.14469-1-richard.weiyang@gmail.com>
 <20170614055925.GA6045@dhcp22.suse.cz>
 <20170614061959.GD14009@WeideMBP.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170614061959.GD14009@WeideMBP.lan>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 14-06-17 14:19:59, Wei Yang wrote:
> On Wed, Jun 14, 2017 at 07:59:25AM +0200, Michal Hocko wrote:
> >On Wed 14-06-17 13:45:50, Wei Yang wrote:
> >> Based on Greg's comment, cc it to mm list.
> >> The original thread could be found https://lkml.org/lkml/2017/6/7/202
> >
> 
> Wow, you are still working~ I just moved your response in this thread~
> 
> So that other audience would be convenient to see the whole story.

You could add linux-mm to the cc in the response to that email
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9A4146B02EE
	for <linux-mm@kvack.org>; Tue,  2 May 2017 03:31:43 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id p134so796858wmg.3
        for <linux-mm@kvack.org>; Tue, 02 May 2017 00:31:43 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u11si20341775wru.73.2017.05.02.00.31.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 May 2017 00:31:42 -0700 (PDT)
Date: Tue, 2 May 2017 09:31:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: 4.11.0-rc8+/x86_64 desktop lockup until applications closed
Message-ID: <20170502073138.GA14593@dhcp22.suse.cz>
References: <md5:RQiZYAYNN/yJzTrY48XZ7w==>
 <ccd5aac8-b24a-713a-db54-c35688905595@internode.on.net>
 <20170427092636.GD4706@dhcp22.suse.cz>
 <99a78105-de58-a5e1-5191-d5f4de7ed5f4@internode.on.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <99a78105-de58-a5e1-5191-d5f4de7ed5f4@internode.on.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arthur Marsh <arthur.marsh@internode.on.net>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Sun 30-04-17 15:33:50, Arthur Marsh wrote:
> 
> 
> Michal Hocko wrote on 27/04/17 18:56:
> >On Thu 27-04-17 18:36:38, Arthur Marsh wrote:
> >[...]
> >>[55363.482931] QXcbEventReader: page allocation stalls for 10048ms, order:0,
> >>mode:0x14200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null)
> >
> >Are there more of these stalls?
> 
> I haven't seen the same kinds of logging in dmesg, but a few minutes ago I
> did see that the desktop had locked up and after remotely logging in and
> doing a kill -HUP of iceweasel/firefox, saw this:
> 
> [92311.944443] swap_info_get: Bad swap offset entry 000ffffd
> [92311.944449] swap_info_get: Bad swap offset entry 000ffffe
> [92311.944451] swap_info_get: Bad swap offset entry 000fffff

Pte swap entry seem to be clobbered. That suggests a deeper problem and
a memory corruption.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

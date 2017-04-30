Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 03D006B0038
	for <linux-mm@kvack.org>; Sun, 30 Apr 2017 02:03:59 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id m89so60503937pfi.14
        for <linux-mm@kvack.org>; Sat, 29 Apr 2017 23:03:58 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id r78si11065144pfi.203.2017.04.29.23.03.56
        for <linux-mm@kvack.org>;
        Sat, 29 Apr 2017 23:03:57 -0700 (PDT)
Subject: Re: 4.11.0-rc8+/x86_64 desktop lockup until applications closed
References: <md5:RQiZYAYNN/yJzTrY48XZ7w==>
 <ccd5aac8-b24a-713a-db54-c35688905595@internode.on.net>
 <20170427092636.GD4706@dhcp22.suse.cz>
From: Arthur Marsh <arthur.marsh@internode.on.net>
Message-ID: <99a78105-de58-a5e1-5191-d5f4de7ed5f4@internode.on.net>
Date: Sun, 30 Apr 2017 15:33:50 +0930
MIME-Version: 1.0
In-Reply-To: <20170427092636.GD4706@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org



Michal Hocko wrote on 27/04/17 18:56:
> On Thu 27-04-17 18:36:38, Arthur Marsh wrote:
> [...]
>> [55363.482931] QXcbEventReader: page allocation stalls for 10048ms, order:0,
>> mode:0x14200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null)
>
> Are there more of these stalls?

I haven't seen the same kinds of logging in dmesg, but a few minutes ago 
I did see that the desktop had locked up and after remotely logging in 
and doing a kill -HUP of iceweasel/firefox, saw this:

[92311.944443] swap_info_get: Bad swap offset entry 000ffffd
[92311.944449] swap_info_get: Bad swap offset entry 000ffffe
[92311.944451] swap_info_get: Bad swap offset entry 000fffff

I've since restarted that machine, but should it happen again I'd be 
happy to run further tests.

Arthur.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

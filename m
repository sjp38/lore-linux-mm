Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id D96466B0253
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 11:08:41 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so145128352wic.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 08:08:41 -0700 (PDT)
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com. [209.85.212.181])
        by mx.google.com with ESMTPS id bn9si17773941wib.0.2015.09.14.08.08.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 08:08:40 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so145127615wic.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 08:08:40 -0700 (PDT)
Date: Mon, 14 Sep 2015 17:08:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: how can I solve this grep problem
Message-ID: <20150914150838.GA7055@dhcp22.suse.cz>
References: <CAEqaY8cE7C2UvQP5x6VswOG46Gn+W+NYzWvFyqwXSjLaaTZBJg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAEqaY8cE7C2UvQP5x6VswOG46Gn+W+NYzWvFyqwXSjLaaTZBJg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?iso-8859-1?Q?=D6zkan?= Pakdil <ozkan.pakdil@gmail.com>
Cc: linux-mm@kvack.org

On Mon 14-09-15 05:20:47, Ozkan Pakdil wrote:
> Hello
> 
> I was searching some strings in my disk yes I mean whole disk like this
> 
> find / -type f -exec grep -sl "access denied" {} \;
> 
> then I start seeing this messages
> 
> [121338.113923] do_IRQ: 3.228 No irq handler for vector (irq -1)
> 
> when I check the dmesg I saw some others and one of them was like this
> 
> [ 6181.655960] grep: The scan_unevictable_pages sysctl/node-interface has
> been disabled for lack of a legitimate use case.  If you have one, please
> send an email to linux-mm@kvack.org.

Your find has encountered /proc/sys/vm/scan_unevictable_pages and
reading that file triggers the above warning which has been added to
warn people that this file would go away. This has actually happened in
3.18 (1f13ae399c58 "mm: remove noisy remainder of the scan_unevictable
interface").

> this is why I am sending this email. how can I solve this message ?

You do not have to care about it at all because you weren't reading that
file to get a "reasonable" value.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

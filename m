Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 36A206B0038
	for <linux-mm@kvack.org>; Mon, 19 May 2014 12:00:47 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so3868045eei.28
        for <linux-mm@kvack.org>; Mon, 19 May 2014 09:00:46 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p43si11388576eeg.15.2014.05.19.09.00.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 May 2014 09:00:45 -0700 (PDT)
Date: Mon, 19 May 2014 18:00:44 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [1657.328473] i915 0000:00:02.0: VGA-1:ignorin invalid EDID
 block 31.
Message-ID: <20140519160044.GB3140@dhcp22.suse.cz>
References: <CAFjkN8MqZmWhXOEaeMmWWE9n_9_gfh+H23UHPmB8KsYhk0njDA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFjkN8MqZmWhXOEaeMmWWE9n_9_gfh+H23UHPmB8KsYhk0njDA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jose Marin <orlandojose3@gmail.com>
Cc: linux-mm@kvack.org

On Wed 14-05-14 00:05:42, Jose Marin wrote:
> [2392.789674]tracker-miner-f [3824]: segfault at 2 ip b7771967 sp bfc 88210
> error  in lib tracker-miner-0.14.so.0.140.1 [b 7750000 + 33000]

This message seems to be unrelated.

> [14037.061151  the scan_unevictable_pages sys tl/node-interface has been
> disabled for lack  of a legitimate use case.
> Tanks if you can help my

It would be much more helpful to check who is calling this sysctl
because the message tells us that we are _looking for_ legitimate use
cases. I would bet this is a result of sysctl -a which is not
something we would want to keep the sysctl alive. 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

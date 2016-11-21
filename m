Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7442B6B04D8
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 00:31:59 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id g23so31883507wme.4
        for <linux-mm@kvack.org>; Sun, 20 Nov 2016 21:31:59 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 13si11966745wmb.71.2016.11.20.21.31.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 20 Nov 2016 21:31:58 -0800 (PST)
Date: Mon, 21 Nov 2016 06:31:55 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Softlockup during memory allocation
Message-ID: <20161121053154.GA29816@dhcp22.suse.cz>
References: <e3177ea6-a921-dac9-f4f3-952c14e2c4df@kyup.com>
 <a73f4917-48ac-bf1e-04d9-64fb937abfc6@kyup.com>
 <CAJFSNy5_z_FA4DTPAtqBdOU+LmnfvdeVBtDhHuperv1MVU-9VA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJFSNy5_z_FA4DTPAtqBdOU+LmnfvdeVBtDhHuperv1MVU-9VA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <kernel@kyup.com>
Cc: Linux MM <linux-mm@kvack.org>

Hi,
I am sorry for a late response, but I was offline until this weekend. I
will try to get to this email ASAP but it might take some time.

On Mon 14-11-16 00:02:57, Nikolay Borisov wrote:
> Ping on that Michal, in case you've missed it. This seems like a
> genuine miss of a cond_resched. Can you at least confirm my analysis
> or is it complete bollocks?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

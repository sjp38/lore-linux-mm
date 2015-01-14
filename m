Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 08E846B0032
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 16:27:50 -0500 (EST)
Received: by mail-qa0-f49.google.com with SMTP id v8so8532343qal.8
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 13:27:49 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 22si32817408qga.22.2015.01.14.13.27.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jan 2015 13:27:48 -0800 (PST)
Date: Wed, 14 Jan 2015 22:27:45 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [LSF/MM TOPIC ATTEND]
Message-ID: <20150114212745.GQ6103@redhat.com>
References: <20150106161435.GF20860@dhcp22.suse.cz>
 <xr93k30zij6o.fsf@gthelen.mtv.corp.google.com>
 <20150107142804.GD16553@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150107142804.GD16553@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Greg Thelen <gthelen@google.com>, linux-mm@kvack.org

Hello everyone,

On Wed, Jan 07, 2015 at 03:28:04PM +0100, Michal Hocko wrote:
> Instead we shouldn't pretend that GFP_KERNEL is basically GFP_NOFAIL.
> The question is how to get there without too many regressions IMHO.
> Or maybe we should simply bite a bullet and don't be cowards and simply
> deal with bugs as they come. If something really cannot deal with the
> failure it should tell that by a proper flag.

Not related to memcg but related to GFP_NOFAIL behavior, a couple of
months ago while stress testing some code I've been working on, I run
into several OOM livelocks which may be the same you're reporting here
and I reliably fixed those (at least for my load) so I could keep
going with my work. I didn't try to submit these changes yet, but this
discussion rings a bell... so I'm sharing my changes below in this
thread in case it may help:

http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?id=00e91f97df9861454f7e0701944d7de2c382ffb9
http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?id=a0fcf2323b2e4cffd750c1abc1d2c138acdefcc8
http://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?id=798b7f9d549664f8c0007c6416a2568eedd75d6a

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

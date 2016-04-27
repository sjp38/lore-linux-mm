Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id A5AC76B025E
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 08:31:42 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id 68so35353969lfq.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 05:31:42 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id uu10si4165908wjc.123.2016.04.27.05.31.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 05:31:41 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id n129so3276527wmn.1
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 05:31:41 -0700 (PDT)
Date: Wed, 27 Apr 2016 14:31:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Confusing olddefault prompt for Z3FOLD
Message-ID: <20160427123139.GA2230@dhcp22.suse.cz>
References: <9459.1461686910@turing-police.cc.vt.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9459.1461686910@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Cc: Vitaly Wool <vitalywool@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 26-04-16 12:08:30, Valdis Kletnieks wrote:
> Saw this duplicate prompt text in today's linux-next in a 'make oldconfig':
> 
> Low density storage for compressed pages (ZBUD) [Y/n/m/?] y
> Low density storage for compressed pages (Z3FOLD) [N/m/y/?] (NEW) ?
> 
> I had to read the help texts for both before I clued in that one used
> two compressed pages, and the other used 3.
> 
> And 'make oldconfig' doesn't have a "Wait, what?" option to go back
> to a previous prompt....
> 
> (Change Z3FOLD prompt to "New low density" or something? )

Or even better can we only a single one rather than 2 algorithms doing
the similar thing? I wasn't following this closely but what is the
difference to have them both?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

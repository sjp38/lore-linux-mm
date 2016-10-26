Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id ADA0A6B0276
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 08:47:55 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l124so3680723wml.4
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 05:47:55 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id a8si1047147wja.149.2016.10.26.05.47.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 05:47:54 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id 79so3516742wmy.4
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 05:47:54 -0700 (PDT)
Date: Wed, 26 Oct 2016 14:47:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH stable 4.4 2/4] mm: filemap: don't plant shadow entries
 without radix tree node
Message-ID: <20161026124753.GG18382@dhcp22.suse.cz>
References: <20161025075148.31661-1-mhocko@kernel.org>
 <20161025075148.31661-3-mhocko@kernel.org>
 <20161026124553.GA25683@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161026124553.GA25683@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable tree <stable@vger.kernel.org>, Greg KH <gregkh@linuxfoundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>

On Wed 26-10-16 14:45:53, Michal Hocko wrote:
> Greg,
> I do not see this one in the 4.4 queue you have just sent today.

Scratch that. I can see it now on lkml. I just wasn't on the CC so it
hasn't shown up in my inbox.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

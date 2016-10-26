Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3769E6B027A
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 09:10:46 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id h129so18902466ith.12
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 06:10:46 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o195si2407593ioe.62.2016.10.26.06.10.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 06:10:45 -0700 (PDT)
Date: Wed, 26 Oct 2016 15:10:49 +0200
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH stable 4.4 2/4] mm: filemap: don't plant shadow entries
 without radix tree node
Message-ID: <20161026131049.GA7657@kroah.com>
References: <20161025075148.31661-1-mhocko@kernel.org>
 <20161025075148.31661-3-mhocko@kernel.org>
 <20161026124553.GA25683@dhcp22.suse.cz>
 <20161026124753.GG18382@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161026124753.GG18382@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Stable tree <stable@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>

On Wed, Oct 26, 2016 at 02:47:53PM +0200, Michal Hocko wrote:
> On Wed 26-10-16 14:45:53, Michal Hocko wrote:
> > Greg,
> > I do not see this one in the 4.4 queue you have just sent today.
> 
> Scratch that. I can see it now on lkml. I just wasn't on the CC so it
> hasn't shown up in my inbox.

Sorry about that, I had applied it earlier in the sequence due to it
being part of the "normal" stable request process.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id D4FDC6B0253
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 12:09:36 -0500 (EST)
Received: by mail-yb0-f200.google.com with SMTP id j82so220450349ybg.0
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 09:09:36 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id g203si4310692ybg.325.2017.01.23.09.09.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 09:09:35 -0800 (PST)
Date: Mon, 23 Jan 2017 12:09:24 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [ATTEND] many topics
Message-ID: <20170123170924.ubx2honzxe7g34on@thunk.org>
References: <20170118054945.GD18349@bombadil.infradead.org>
 <20170118133243.GB7021@dhcp22.suse.cz>
 <20170119110513.GA22816@bombadil.infradead.org>
 <20170119113317.GO30786@dhcp22.suse.cz>
 <20170119115243.GB22816@bombadil.infradead.org>
 <20170119121135.GR30786@dhcp22.suse.cz>
 <878tq5ff0i.fsf@notabene.neil.brown.name>
 <20170121131644.zupuk44p5jyzu5c5@thunk.org>
 <87ziijem9e.fsf@notabene.neil.brown.name>
 <20170123060544.GA12833@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170123060544.GA12833@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: NeilBrown <neilb@suse.com>, Michal Hocko <mhocko@kernel.org>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Sun, Jan 22, 2017 at 10:05:44PM -0800, Matthew Wilcox wrote:
> 
> I don't have a clear picture in my mind of when Java promotes objects
> from nursery to tenure

It's typically on the order of minutes.   :-)

> ... which is not too different from my lack of
> understanding of what the MM layer considers "temporary" :-)  Is it
> acceptable usage to allocate a SCSI command (guaranteed to be freed
> within 30 seconds) from the temporary area?  Or should it only be used
> for allocations where the thread of control is not going to sleep between
> allocation and freeing?

What the mm folks have said is that it's to prevent fragmentation.  If
that's the optimization, whether or not you the process is allocating
the memory sleeps for a few hundred milliseconds, or even seconds, is
really in the noise compared with the average lifetime of an inode in
the inode cache, or a page in the page cache....

Why do you think it matters whether or not we sleep?  I've not heard
any explanation for the assumption for why this might be important.

    		    		       	   - Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C718B6B0069
	for <linux-mm@kvack.org>; Mon,  3 Oct 2016 13:54:12 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id d64so88999643wmh.1
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 10:54:12 -0700 (PDT)
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id m4si35848849wjk.108.2016.10.03.10.54.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Oct 2016 10:54:11 -0700 (PDT)
Received: by mail-wm0-f45.google.com with SMTP id b201so96127152wmb.0
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 10:54:11 -0700 (PDT)
Date: Mon, 3 Oct 2016 19:54:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Excessive xfs_inode allocations trigger OOM killer
Message-ID: <20161003175407.GA26788@dhcp22.suse.cz>
References: <87a8f2pd2d.fsf@mid.deneb.enyo.de>
 <20160920203039.GI340@dastard>
 <87mvj2mgsg.fsf@mid.deneb.enyo.de>
 <20160920214612.GJ340@dastard>
 <20160921080425.GC10300@dhcp22.suse.cz>
 <878tuetvl6.fsf@mid.deneb.enyo.de>
 <20160926200209.GA23827@dhcp22.suse.cz>
 <878tu5xrmx.fsf@mid.deneb.enyo.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <878tu5xrmx.fsf@mid.deneb.enyo.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fw@deneb.enyo.de>
Cc: Dave Chinner <david@fromorbit.com>, xfs@oss.sgi.com, linux-xfs@vger.kernel.org, linux-mm@kvack.org

On Mon 03-10-16 19:35:18, Florian Weimer wrote:
> * Michal Hocko:
> 
> >> I'm not sure if I can reproduce this issue in a sufficiently reliable
> >> way, but I can try.  (I still have not found the process which causes
> >> the xfs_inode allocations go up.)
> >> 
> >> Is linux-next still the tree to test?
> >
> > Yes it contains all the compaction related fixes which we believe to
> > address recent higher order OOMs.
> 
> I tried 4.7.5 instead.  I could not reproduce the issue so far there.
> Thanks to whoever fixed it. :)

The 4.7 stable tree contains a workaround rather than the full fix we
would like to have in 4.9. So if you can then testing the current
linux-next would be really appreciated.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

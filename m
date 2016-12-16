Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id AD9AB6B0038
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 17:00:31 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id m203so11152791wma.2
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 14:00:31 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id 199si5354295wmi.91.2016.12.16.14.00.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 14:00:30 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id u144so7816533wmu.0
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 14:00:30 -0800 (PST)
Date: Fri, 16 Dec 2016 23:00:28 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 5/9 v2] xfs: use memalloc_nofs_{save,restore} instead of
 memalloc_noio*
Message-ID: <20161216220028.GB7645@dhcp22.suse.cz>
References: <20161215140715.12732-1-mhocko@kernel.org>
 <20161215140715.12732-6-mhocko@kernel.org>
 <20161216163811.GG8447@bfoster.bfoster>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161216163811.GG8447@bfoster.bfoster>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Foster <bfoster@redhat.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

On Fri 16-12-16 11:38:11, Brian Foster wrote:
> On Thu, Dec 15, 2016 at 03:07:11PM +0100, Michal Hocko wrote:
[...]
> > @@ -459,7 +459,7 @@ _xfs_buf_map_pages(
> >  				break;
> >  			vm_unmap_aliases();
> >  		} while (retried++ <= 1);
> > -		memalloc_noio_restore(noio_flag);
> > +		memalloc_noio_restore(nofs_flag);
> 
> memalloc_nofs_restore() ?

Ups, you are right of course. Fixed.
---

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 0C4A46B0032
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 11:43:55 -0400 (EDT)
Received: by widdi4 with SMTP id di4so24975061wid.0
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 08:43:54 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fq4si19476284wjc.189.2015.04.17.08.43.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 17 Apr 2015 08:43:53 -0700 (PDT)
Date: Fri, 17 Apr 2015 17:43:51 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC 1/4] fs: Add generic file system event notifications
Message-ID: <20150417154351.GA26736@quack.suse.cz>
References: <1429082147-4151-1-git-send-email-b.michalska@samsung.com>
 <1429082147-4151-2-git-send-email-b.michalska@samsung.com>
 <20150417113110.GD3116@quack.suse.cz>
 <553104E5.2040704@samsung.com>
 <55310957.3070101@gmail.com>
 <55311DE2.9000901@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55311DE2.9000901@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Spray <john.spray@redhat.com>
Cc: Austin S Hemmelgarn <ahferroin7@gmail.com>, Beata Michalska <b.michalska@samsung.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org, Linux Filesystem Mailing List <linux-fsdevel@vger.kernel.org>, linux-api@vger.kernel.org

On Fri 17-04-15 15:51:14, John Spray wrote:
> On 17/04/2015 14:23, Austin S Hemmelgarn wrote:
> >On 2015-04-17 09:04, Beata Michalska wrote:
> >>On 04/17/2015 01:31 PM, Jan Kara wrote:
> >>>On Wed 15-04-15 09:15:44, Beata Michalska wrote:
> >>>...
> >>>>+static const match_table_t fs_etypes = {
> >>>>+    { FS_EVENT_INFO,    "info"  },
> >>>>+    { FS_EVENT_WARN,    "warn"  },
> >>>>+    { FS_EVENT_THRESH,  "thr"   },
> >>>>+    { FS_EVENT_ERR,     "err"   },
> >>>>+    { 0, NULL },
> >>>>+};
> >>>   Why are there these generic message types? Threshold
> >>>messages make good
> >>>sense to me. But not so much the rest. If they don't have a
> >>>clear meaning,
> >>>it will be a mess. So I also agree with a message like -
> >>>"filesystem has
> >>>trouble, you should probably unmount and run fsck" - that's fine. But
> >>>generic "info" or "warning" doesn't really carry any meaning
> >>>on its own and
> >>>thus seems pretty useless to me. To explain a bit more, AFAIU this
> >>>shouldn't be a generic logging interface where something like severity
> >>>makes sense but rather a relatively specific interface notifying about
> >>>events in filesystem userspace should know about so I expect
> >>>relatively low
> >>>number of types of events, not tens or even hundreds...
> >>>
> >>>                                Honza
> >>
> >>Getting rid of those would simplify the configuration part, indeed.
> >>So we would be left with 'generic' and threshold events.
> >>I guess I've overdone this part.
> >
> >For some filesystems, it may make sense to differentiate between a
> >generic warning and an error.  For BTRFS and ZFS for example, if
> >there is a csum error on a block, this will get automatically
> >corrected in many configurations, and won't require anything like
> >fsck to be run, but monitoring applications will still probably
> >want to be notified.
> 
> Another key differentiation IMHO is between transient errors (like
> server is unavailable in a distributed filesystem) that will block
> the filesystem but might clear on their own, vs. permanent errors
> like unreadable drives that definitely will not clear until the
> administrator takes some action.  It's usually a reasonable
> approximation to call transient issues warnings, and permanent
> issues errors.
  So you can have events like FS_UNAVAILABLE and FS_AVAILABLE but what use
would this have? I wouldn't like the interface to be dumping ground for
random crap - we have dmesg for that :).

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

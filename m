Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 1403C6B0032
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 12:22:52 -0400 (EDT)
Received: by wgin8 with SMTP id n8so118300392wgi.0
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 09:22:51 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jp5si19635281wjc.175.2015.04.17.09.22.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 17 Apr 2015 09:22:50 -0700 (PDT)
Date: Fri, 17 Apr 2015 18:22:47 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC 1/4] fs: Add generic file system event notifications
Message-ID: <20150417162247.GB27500@quack.suse.cz>
References: <1429082147-4151-1-git-send-email-b.michalska@samsung.com>
 <1429082147-4151-2-git-send-email-b.michalska@samsung.com>
 <20150417113110.GD3116@quack.suse.cz>
 <553104E5.2040704@samsung.com>
 <55310957.3070101@gmail.com>
 <55311DE2.9000901@redhat.com>
 <20150417154351.GA26736@quack.suse.cz>
 <55312FEA.3030905@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55312FEA.3030905@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Spray <john.spray@redhat.com>
Cc: Jan Kara <jack@suse.cz>, Austin S Hemmelgarn <ahferroin7@gmail.com>, Beata Michalska <b.michalska@samsung.com>, linux-kernel@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org, Linux Filesystem Mailing List <linux-fsdevel@vger.kernel.org>, linux-api@vger.kernel.org

On Fri 17-04-15 17:08:10, John Spray wrote:
> 
> On 17/04/2015 16:43, Jan Kara wrote:
> >On Fri 17-04-15 15:51:14, John Spray wrote:
> >>On 17/04/2015 14:23, Austin S Hemmelgarn wrote:
> >>
> >>>For some filesystems, it may make sense to differentiate between a
> >>>generic warning and an error.  For BTRFS and ZFS for example, if
> >>>there is a csum error on a block, this will get automatically
> >>>corrected in many configurations, and won't require anything like
> >>>fsck to be run, but monitoring applications will still probably
> >>>want to be notified.
> >>Another key differentiation IMHO is between transient errors (like
> >>server is unavailable in a distributed filesystem) that will block
> >>the filesystem but might clear on their own, vs. permanent errors
> >>like unreadable drives that definitely will not clear until the
> >>administrator takes some action.  It's usually a reasonable
> >>approximation to call transient issues warnings, and permanent
> >>issues errors.
> >   So you can have events like FS_UNAVAILABLE and FS_AVAILABLE but what use
> >would this have? I wouldn't like the interface to be dumping ground for
> >random crap - we have dmesg for that :).
> In that case I'm confused -- why would ENOSPC be an appropriate use
> of this interface if the mount being entirely blocked would be
> inappropriate?  Isn't being unable to service any I/O a more
> fundamental and severe thing than being up and healthy but full?
> 
> Were you intending the interface to be exclusively for data
> integrity issues like checksum failures, rather than more general
> events about a mount that userspace would probably like to know
> about?
  Well, I'm not saying we cannot have those events for fs availability /
inavailability. I'm just saying I'd like to see some use for that first.
I don't want events to be added just because it's possible...

For ENOSPC we have thin provisioned storage and the userspace deamon
shuffling real storage underneath. So there I know the usecase.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

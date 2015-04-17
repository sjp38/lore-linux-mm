Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4E38A6B0032
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 12:39:18 -0400 (EDT)
Received: by wgso17 with SMTP id o17so119188048wgs.1
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 09:39:17 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id xb3si5465043wjc.178.2015.04.17.09.39.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 17 Apr 2015 09:39:16 -0700 (PDT)
Date: Fri, 17 Apr 2015 18:39:14 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC 1/4] fs: Add generic file system event notifications
Message-ID: <20150417163914.GA28058@quack.suse.cz>
References: <1429082147-4151-1-git-send-email-b.michalska@samsung.com>
 <1429082147-4151-2-git-send-email-b.michalska@samsung.com>
 <20150417113110.GD3116@quack.suse.cz>
 <553104E5.2040704@samsung.com>
 <55310957.3070101@gmail.com>
 <55311DE2.9000901@redhat.com>
 <20150417154351.GA26736@quack.suse.cz>
 <55312FEA.3030905@redhat.com>
 <20150417162247.GB27500@quack.suse.cz>
 <553134D3.9040001@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <553134D3.9040001@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Austin S Hemmelgarn <ahferroin7@gmail.com>
Cc: Jan Kara <jack@suse.cz>, John Spray <john.spray@redhat.com>, Beata Michalska <b.michalska@samsung.com>, linux-kernel@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org, Linux Filesystem Mailing List <linux-fsdevel@vger.kernel.org>, linux-api@vger.kernel.org

On Fri 17-04-15 12:29:07, Austin S Hemmelgarn wrote:
> On 2015-04-17 12:22, Jan Kara wrote:
> >On Fri 17-04-15 17:08:10, John Spray wrote:
> >>
> >>On 17/04/2015 16:43, Jan Kara wrote:
> >>>On Fri 17-04-15 15:51:14, John Spray wrote:
> >>>>On 17/04/2015 14:23, Austin S Hemmelgarn wrote:
> >>>>
> >>>>>For some filesystems, it may make sense to differentiate between a
> >>>>>generic warning and an error.  For BTRFS and ZFS for example, if
> >>>>>there is a csum error on a block, this will get automatically
> >>>>>corrected in many configurations, and won't require anything like
> >>>>>fsck to be run, but monitoring applications will still probably
> >>>>>want to be notified.
> >>>>Another key differentiation IMHO is between transient errors (like
> >>>>server is unavailable in a distributed filesystem) that will block
> >>>>the filesystem but might clear on their own, vs. permanent errors
> >>>>like unreadable drives that definitely will not clear until the
> >>>>administrator takes some action.  It's usually a reasonable
> >>>>approximation to call transient issues warnings, and permanent
> >>>>issues errors.
> >>>   So you can have events like FS_UNAVAILABLE and FS_AVAILABLE but what use
> >>>would this have? I wouldn't like the interface to be dumping ground for
> >>>random crap - we have dmesg for that :).
> >>In that case I'm confused -- why would ENOSPC be an appropriate use
> >>of this interface if the mount being entirely blocked would be
> >>inappropriate?  Isn't being unable to service any I/O a more
> >>fundamental and severe thing than being up and healthy but full?
> >>
> >>Were you intending the interface to be exclusively for data
> >>integrity issues like checksum failures, rather than more general
> >>events about a mount that userspace would probably like to know
> >>about?
> >   Well, I'm not saying we cannot have those events for fs availability /
> >inavailability. I'm just saying I'd like to see some use for that first.
> >I don't want events to be added just because it's possible...
> >
> >For ENOSPC we have thin provisioned storage and the userspace deamon
> >shuffling real storage underneath. So there I know the usecase.
> >
> The use-case that immediately comes to mind for me would be diskless
> nodes with root-on-nfs needing to know if they can actually access
> the root filesystem.
  Well, most apps will access the root file system regardless of what we
send over netlink... So I don't see netlink events improving the situation
there too much. You could try to use it for something like failover but
even there I'm not too convinced - just doing some IO, waiting for timeout,
and failing over if IO doesn't complete works just fine for that these
days. That's why I was asking because I didn't see convincing usecase
myself...

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

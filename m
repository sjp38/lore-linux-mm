Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 6E1F66B00F9
	for <linux-mm@kvack.org>; Wed,  4 Apr 2012 14:56:12 -0400 (EDT)
Received: by dakh32 with SMTP id h32so745361dak.9
        for <linux-mm@kvack.org>; Wed, 04 Apr 2012 11:56:11 -0700 (PDT)
Date: Wed, 4 Apr 2012 11:56:05 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [Lsf] [RFC] writeback and cgroup
Message-ID: <20120404185605.GC29686@dhcp-172-17-108-109.mtv.corp.google.com>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
 <20120404145134.GC12676@redhat.com>
 <CAH2r5mtwQa0Uu=_Yd2JywVJXA=OMGV43X_OUfziC-yeVy9BGtQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAH2r5mtwQa0Uu=_Yd2JywVJXA=OMGV43X_OUfziC-yeVy9BGtQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve French <smfrench@gmail.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, ctalbott@google.com, rni@google.com, andrea@betterlinux.com, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, lsf@lists.linux-foundation.org, linux-mm@kvack.org, jmoyer@redhat.com, lizefan@huawei.com, linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org

On Wed, Apr 04, 2012 at 10:36:04AM -0500, Steve French wrote:
> > How do you take care of thorottling IO to NFS case in this model? Current
> > throttling logic is tied to block device and in case of NFS, there is no
> > block device.
> 
> Similarly smb2 gets congestion info (number of "credits") returned from
> the server on every response - but not sure why congestion
> control is tied to the block device when this would create
> problems for network file systems

I hope the previous replies answered this.  It's about writeback
getting pressure from bdi and isn't restricted to block devices.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

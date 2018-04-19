Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id D0FD16B0003
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 10:38:28 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id k22-v6so3530104qtm.4
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 07:38:28 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id y4si477589qve.161.2018.04.19.07.38.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Apr 2018 07:38:27 -0700 (PDT)
Date: Thu, 19 Apr 2018 10:38:25 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [LSF/MM] schedule suggestion
Message-ID: <20180419143825.GA3519@redhat.com>
References: <20180418211939.GD3476@redhat.com>
 <20180419015508.GJ27893@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180419015508.GJ27893@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-block@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>

On Thu, Apr 19, 2018 at 11:55:08AM +1000, Dave Chinner wrote:
> On Wed, Apr 18, 2018 at 05:19:39PM -0400, Jerome Glisse wrote:
> > Just wanted to suggest to push HMM status down one slot in the
> > agenda to avoid having FS and MM first going into their own
> > room and then merging back for GUP and DAX, and re-splitting
> > after. More over HMM and NUMA talks will be good to have back
> > to back as they deal with same kind of thing mostly.
> 
> So while we are talking about schedule suggestions, we see that
> there's lots of empty slots in the FS track. We (xfs guys) were just
> chatting on #xfs about whether we'd have time to have a "XFS devel
> meeting" at some point during LSF/MM as we are rarely in the same
> place at the same time.
> 
> I'd like to propose that we compact the fs sessions so that we get a
> 3-slot session reserved for "Individual filesystem discussions" one
> afternoon. That way we've got time in the schedule for the all the
> ext4/btrfs/XFS/NFS/CIFS devs to get together with each other and
> talk about things of interest only to their own fileystems.
> 
> That means we all don't have to find time outside the schedule to do
> this, and think this wold be time very well spent for most fs people
> at the conf....

Oh can i get one more small slot for fs ? I want to ask if they are
any people against having a callback everytime a struct file is added
to a task_struct and also having a secondary array so that special
file like device file can store something opaque per task_struct per
struct file.

I will try to stich a patchset tomorrow for that. A lot of device
driver would like to have this.

Cheers,
Jerome

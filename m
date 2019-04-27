Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8799FC43219
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 01:25:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 370202077B
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 01:25:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 370202077B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7EE986B0003; Fri, 26 Apr 2019 21:25:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 79FF86B0005; Fri, 26 Apr 2019 21:25:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 667AA6B0006; Fri, 26 Apr 2019 21:25:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2B3926B0003
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 21:25:24 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d21so3269249pfr.3
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 18:25:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=SOWsjeP6xa7lazbbQzS4/vd2ku6Z5vD0vsaswtuT2CY=;
        b=naexmJKoI0iz8vfhN8K2MY1wW6aByqdSmpM1PpdH2uiD7dqVeJhS3FBzhNRADrw8Cq
         jldOVdzwZCPkzqv/i4CohdB8o4h6qG+2gcX7dFh6wIQJIHG1aaRNHrcz7tpXuX9o0BoV
         +8XUz+vo8is5UVhEazI2ukbhP7XWJkDQtK6w1VBXzrrMkjoemWvFwpVqjs3leYBpOnfk
         rimUROhFBMlXXv/62PEF+4CUHqBddE2N4c1MJnuzS3gW4H6xBWUa4VCnezUQbEln38Nl
         dVC9auOrjVAumpGXc+3q/0+Q67/bCKZGuZSQXC6LNAnT3tbTSBYSNC2Sfq/Q9xGeWiaz
         /bZA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAWz/GoR2IUXz/ZqUYPXV9lI45b9b8cluGqBhgRbnAshPBDloooZ
	537qsuD4EIdOU17L3ewkfq+PRvbBCCOUIwpKsqbvPbX+0wqMgicYOYHO7BHMk5vaXz1GC5UiNE6
	cDcukiMUMlWO/0xZlL6s3opa0m1Rqpetmd2PyFHp4oFmnnMSZLG/vgdZSMbB226s=
X-Received: by 2002:a17:902:29a7:: with SMTP id h36mr49678252plb.319.1556328323638;
        Fri, 26 Apr 2019 18:25:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxp6Ggs8K7KmsjgQT1GgANXcTQWFwZTgd82LAl1CspMvn8U6sjkZ829VZ/jVzo8Ya/m6BaE
X-Received: by 2002:a17:902:29a7:: with SMTP id h36mr49678149plb.319.1556328322074;
        Fri, 26 Apr 2019 18:25:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556328322; cv=none;
        d=google.com; s=arc-20160816;
        b=ZOzQEYnZ8BBvE5Dzd5z4PenIotushAecSg5wSsuMcoWHe7B7BrfOtSKr0ILJwLhqZT
         F1KAeBcbvBh2faOiBx3cCmISzziXEQiYuu1svf0N163ZAxprRm13Ef/RoPRqFHFiaHJI
         ivZ7YFc1/elFU6DtyIMy6RrbWGmx4W+kQld6bMiDrK7lVotgoobvzz4FAddUCIbJn1Pp
         xwgYtwUEN66dxngQa9fbcC8OGJUU+HQtmg/bQNylkZTu2M9ZhbbhLGWvLZv6CqOadiIN
         VodZKhcHF87gb0ZfWCkdvzc7M8pwA7JeSbcQQk9xIDGJKD+BmEdXF1elg3BJ48TnO9OK
         HnyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=SOWsjeP6xa7lazbbQzS4/vd2ku6Z5vD0vsaswtuT2CY=;
        b=P57zUctlUBypdDV6PKkIfWBAnUDyTBqKPq5FjA7XF4o+L0eLAps06oRkLusCuUpC16
         9R08A7sAVt5LJlwMhuiVTS5o8z37GHqx2z71j7e8eUmdbett586WDK7X+KhHp+Cu9vRW
         m15rhGq84I/K9ENm7RVeY7K41xbH41O4NenHAb2FzFCt13a+XXhrUcUoBtO0GrqAWxsK
         EtOYKyEP8E97NksCoxcwqdvrBqSb0I5voWCeT4/WynaG9wd/xMBckURPoh8tQoplUp+t
         f8BRAuptH5WJFXNskbtmHgPwEsNOeq1H965E4ztHpjluh58axcl1+x06vEbMbIIF3n6p
         qk9w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au. [211.29.132.249])
        by mx.google.com with ESMTP id e16si2527485pfd.3.2019.04.26.18.25.21
        for <linux-mm@kvack.org>;
        Fri, 26 Apr 2019 18:25:22 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.249;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-181-171-240.pa.nsw.optusnet.com.au [49.181.171.240])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id D3AB510D444;
	Sat, 27 Apr 2019 11:25:17 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hKC5c-0004jm-8u; Sat, 27 Apr 2019 11:25:16 +1000
Date: Sat, 27 Apr 2019 11:25:16 +1000
From: Dave Chinner <david@fromorbit.com>
To: Jerome Glisse <jglisse@redhat.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [LSF/MM TOPIC] Direct block mapping through fs for device
Message-ID: <20190427012516.GH1454@dread.disaster.area>
References: <20190426013814.GB3350@redhat.com>
 <20190426062816.GG1454@dread.disaster.area>
 <20190426152044.GB13360@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190426152044.GB13360@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=P6RKvmIu c=1 sm=1 tr=0 cx=a_idp_d
	a=LhzQONXuMOhFZtk4TmSJIw==:117 a=LhzQONXuMOhFZtk4TmSJIw==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=oexKYjalfGEA:10
	a=7-415B0cAAAA:8 a=SilY-4-awVSwrndW5ZYA:9 a=hHpGJbNLqnb1Yhi3:21
	a=WGQLJQAUvfBwYTRy:21 a=CjuIK1q_8ugA:10 a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 26, 2019 at 11:20:45AM -0400, Jerome Glisse wrote:
> On Fri, Apr 26, 2019 at 04:28:16PM +1000, Dave Chinner wrote:
> > On Thu, Apr 25, 2019 at 09:38:14PM -0400, Jerome Glisse wrote:
> > > I see that they are still empty spot in LSF/MM schedule so i would like to
> > > have a discussion on allowing direct block mapping of file for devices (nic,
> > > gpu, fpga, ...). This is mm, fs and block discussion, thought the mm side
> > > is pretty light ie only adding 2 callback to vm_operations_struct:
> > 
> > The filesystem already has infrastructure for the bits it needs to
> > provide. They are called file layout leases (how many times do I
> > have to keep telling people this!), and what you do with the lease
> > for the LBA range the filesystem maps for you is then something you
> > can negotiate with the underlying block device.
> > 
> > i.e. go look at how xfs_pnfs.c works to hand out block mappings to
> > remote pNFS clients so they can directly access the underlying
> > storage. Basically, anyone wanting to map blocks needs a file layout
> > lease and then to manage the filesystem state over that range via
> > these methods in the struct export_operations:
> > 
> >         int (*get_uuid)(struct super_block *sb, u8 *buf, u32 *len, u64 *offset);
> >         int (*map_blocks)(struct inode *inode, loff_t offset,
> >                           u64 len, struct iomap *iomap,
> >                           bool write, u32 *device_generation);
> >         int (*commit_blocks)(struct inode *inode, struct iomap *iomaps,
> >                              int nr_iomaps, struct iattr *iattr);
> > 
> > Basically, before you read/write data, you map the blocks. if you've
> > written data, then you need to commit the blocks (i.e. tell the fs
> > they've been written to).
> > 
> > The iomap will give you a contiguous LBA range and the block device
> > they belong to, and you can then use that to whatever smart DMA stuff
> > you need to do through the block device directly.
> > 
> > If the filesystem wants the space back (e.g. because truncate) then
> > the lease will be revoked. The client then must finish off it's
> > outstanding operations, commit them and release the lease. To access
> > the file range again, it must renew the lease and remap the file
> > through ->map_blocks....
> 
> Sorry i should have explain why lease do not work. Here are list of
> lease shortcoming AFAIK:
>     - only one process

Sorry, what? The lease is taken by a application process that then
hands out the mapping to whatever parts of it - processes, threads,
remote clients, etc - need access. If your application doesn't
have an access co-ordination method, then you're already completely
screwed.

>     - program ie userspace is responsible for doing the right thing
>       so heavy burden on userspace program

You're asking for direct access to storage owned by the filesystem.
The application *must* play by the filesystem rules. Stop trying to
hack around the fact that the filesystem controls access to the
block mapping.

>     - lease break time induce latency

Lease breaks should never happen in normal workloads, so this isn't
an issue. IF you have an application that requires exclusive access,
then ensure that the file can only be accessed by the application
and the lease should never be broken.

But if you are going to ask for filesystems to hand out block
mapping for thrid party access, the 3rd parties need to play by the
filesystem's access rules, and that means they /must/ break access
if the filesystem asks them to.

>     - lease may require privileges for the applications

If you can directly access the underlying block device (which
requires root/CAP_SYS_ADMIN) then the application has sufficient
privilege to get a file layout lease.

>     - work on file descriptor not virtual addresses

Sorry, what? You want direct access to the underlying storage device
for direct DMA, not access to the page cache. i.e. you need a
mapping for a range of a file (from offset X to Y) and you most
definitely do not need the file to be virtually mapped for that.

If you want to DMA from a userspace or peer device memory to storage
directly, then you definitely do not want the file to mapped into
the page cache, and so mmap() is most definitely the wrong interface
to be using to set up direct storage access to a file.

> While what i am trying to achieve is:
>     - support any number of process

file leases don't prevent that.

>     - work on virtual addresses

like direct io, get_user_pages() works just fine for this.

>     - is an optimization ie falling back to page cache is _always_
>       acceptable

No, it isn't. Falling back to the page cache will break the layout
lease because the lock filesystem does IO that breaks existing
leases. You can't have both a layout lease and page cache access to
the same file.

>     - no changes to userspace program ie existing program can
>       benefit from this by just running on a kernel with the
>       feature on the system with hardware that support this.

That's a pipe dream. Existing direct access applications /don't work/ with
file-backed mmap() ranges. They will not work with DAX, either, so
please stop with the "work with unmodified existing applications"
already.

If you want peer to peer DMA to filesystem managed storage, then you
*must* use the filesystem to manage access to that storage.

>     - allow multiple different devices to map the block (can be
>       read only if the fabric between devices is not cache coherent)

Nothing about a layout lease prevents that. What the application
does with the layout lease is it's own business.

>     - it is an optimization ie avoiding to waste main memory if file
>       is only accessed by device

Layout leases don't prevent this - they are explicitly for allowing
this sort of access to be made safely.

>     - there is _no pin_ and it can be revoke at _any_ time from within
>       the kernel ie there is no need to rely on application to do the
>       right thing

Revoke how, exactly? Are you really proposing sending SEGV to user
processes as the revoke mechanism?

>     - not only support filesystem but also vma that comes from device
>       file

What's a "device file" and how is that any difference from a normal
kernel file?

> The motivation is coming from new storage technology (NVMe with CMB for
> instance) where block device can offer byte addressable access to block.
> It can be read only or read and write. When you couple this with gpu,
> fgpa, tpu that can crunch massive data set (in the tera bytes ranges)
> then avoiding going through main memory becomes an appealing prospect.
>
> If we can achieve that with no disruption to the application programming
> model the better it is. By allowing to mediate direct block access through
> vma we can achieve that.

I have a hammer that I can use to mediate direct block access, too.

That doesn't mean it's the right tool for the job. At it's most
fundamental level, the block mapping is between an inode, the file
offset and the LBA range in the block device that the storage device
presents to users. This is entirely /filesystem information/ and we
already have interfaces to manage and arbitrate safe direct storage
access for third parties.

Stop trying to re-invent the wheel and use the one we already have.

> This is why i am believe something at the vma level is better suited to
> make such thing as easy and transparent as possible. Note that unlike
> GUP there is _no pinning_ so filesystem is always in total control and
> can revoke at _any_ time.

Revoke how, exactly? And how do applications pause and restart when
this undefined revoke mechanism is invoked? What happens to access
latency when this revoke occurs and why is this any different to
having a file layout lease revoked?

> Also because it is all kernel side we should
> achieve much better latency (flushing device page table is usualy faster
> then switching to userspace and having userspace calling back into the
> driver).
> 
> 
> > 
> > > So i would like to gather people feedback on general approach and few things
> > > like:
> > >     - Do block device need to be able to invalidate such mapping too ?
> > > 
> > >       It is easy for fs the to invalidate as it can walk file mappings
> > >       but block device do not know about file.
> > 
> > If you are needing the block device to invalidate filesystem level
> > information, then your model is all wrong.
> 
> It is _not_ a requirement. It is a feature and it does not need to be
> implemented right away the motivation comes from block device that can
> manage their PCIE BAR address space dynamicly and they might want to
> unmap some block to make room for other block. For this they would need
> to make sure that they can revoke access from device or CPU they might
> have mapped the block they want to evict.

This has nothing to do with the /layout lease/. Layout leases are
for managing direct device access, not how the application interacts
with the hardware that it has been given a block mapping for.

Jerome, it seems to me like you're conflating hardware management
issues with block device access and LBA management. These are
completely separate things that the application has to manage - the
filesystem and the layout lease doesn't give a shit about whether
the application has exhausted the hardware PCIE BAR space.  i.e.
hardware kicking out a user address mapping does not invalidate the
layout lease in any way - it just requires the application to set up
that direct access map in the hardware again.  The file offset to
LBA mapping that the layout lease manages is entirely unaffected by
this sort of problem.

> > >     - Maybe some share helpers for block devices that could track file
> > >       corresponding to peer mapping ?
> > 
> > If the application hasn't supplied the peer with the file it needs
> > to access, get a lease from and then map an LBA range out of, then
> > you are doing it all wrong.
> 
> I do not have the same programming model than one you have in mind, i
> want to allow existing application which mmap files and access that
> mapping through a device or CPU to directly access those blocks through
> the virtual address.

Which is the *wrong model*.

mmap() of a file-backed mapping does not provide a sane, workable
direct storage access management API. It's fundamentally flawed
because it does not provide any guarantee about the underlying
filesystem information (e.g. the block mapping) and as such, results
in a largely unworkable model that we need all sorts of complexity
to sorta make work.

Layout leases and the export ops provide the application with the
exact information they need to directly access the storage
underneath the filesystem in a safe manner. They do not, in any way,
control how the application then uses that information. If you
really want to use mmap() to access the storage, then you can mmap()
the ranges of the block device the ->map_blocks() method tells you
belong to that file. 

You can do whatever you want with those vmas and the filesystem
doesn't care - it's not involved in /any way whatsoever/ with the
data transfer into and out of the storage because ->map_blocks has
guaranteed that the storage is allocated. All the application needs
to do is call ->commit_blocks on each range of the mapping it writes
data into to tell the filesystem it now contains valid data.  It's
simple, straight forward, and hard to get wrong from both userspace
and the kernel filesystem side.

Please stop trying to invent new and excitingly complex ways to do
direct block access because we ialready have infrastructure we know
works, we already support and is flexible enough to provide exactly
the sort of direct block device access mechainsms that you are
asking for.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com


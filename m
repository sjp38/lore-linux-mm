Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9B4DA6B0253
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 16:26:19 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 1so88898387wmz.2
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 13:26:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d62si17690733wmd.27.2016.08.01.13.26.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 01 Aug 2016 13:26:18 -0700 (PDT)
Date: Mon, 1 Aug 2016 22:26:16 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: OOM killer changes
Message-ID: <20160801202616.GG31957@dhcp22.suse.cz>
References: <20160801061625.GA11623@dhcp22.suse.cz>
 <b1a39756-a0b5-1900-6575-d6e1f502cb26@Quantum.com>
 <20160801182358.GB31957@dhcp22.suse.cz>
 <30dbabc4-585c-55a5-9f3a-4e243c28356a@Quantum.com>
 <20160801192620.GD31957@dhcp22.suse.cz>
 <939def12-3fa8-e877-ce17-b59db9fa1876@Quantum.com>
 <20160801194323.GE31957@dhcp22.suse.cz>
 <d8116023-dcd4-8763-af77-f2889f84cdb6@Quantum.com>
 <20160801200926.GF31957@dhcp22.suse.cz>
 <3c022d92-9c96-9022-8496-aa8738fb7358@quantum.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3c022d92-9c96-9022-8496-aa8738fb7358@quantum.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>

On Mon 01-08-16 13:16:49, Ralf-Peter Rohbeck wrote:
> 
> 
> On 08/01/16 13:09, Michal Hocko wrote:
> > On Mon 01-08-16 12:52:40, Ralf-Peter Rohbeck wrote:
[...]
> > > root@fs:~# lsscsi
> > > [0:2:0:0]    disk    LSI      MR9271-8iCC      3.29  /dev/sda
> > > [0:2:1:0]    disk    LSI      MR9271-8iCC      3.29  /dev/sdb
> > > [9:0:0:0]    disk    TOSHIBA  External USB 3.0 5438  /dev/sdf
> > > [10:0:0:0]   disk    Seagate  Backup+ Desk     050B  /dev/sdc
> > > [11:0:0:0]   disk    Seagate  Expansion Desk   9400  /dev/sdd
> > > [12:0:0:0]   disk    Seagate  Backup+ Desk     050B /dev/sde
> > > [13:0:0:0]   disk    Seagate  Expansion Desk   9400 /dev/sdg
> > > [14:0:0:0]   disk    TOSHIBA  External USB 3.0 5438 /dev/sdl
> > > [15:0:0:0]   disk    Seagate  Expansion Desk   9400 /dev/sdh
> > > [16:0:0:0]   disk    Seagate  Expansion Desk   9400 /dev/sdi
> > > [17:0:0:0]   disk    TOSHIBA  External USB 3.0 5438 /dev/sdm
> > > [18:0:0:0]   disk    Seagate  Expansion Desk   9400 /dev/sdj
> > > [19:0:0:0]   disk    Seagate  Expansion Desk   9400  /dev/sdk
> > > 
> > > sda is a 6x 1TB RAID5 and sdb is a single 480GB SSD, both on a MegaRAID
> > > controller.
> > > 
> > > The rest are 4TB USB drives that I'm experimenting with.
> > Which devices did you write when hitting the OOM killer?
> sdc, sdd and sde each at max speed, with a little bit of garden variety IO
> on sda and sdb.

So do I get it right that the majority of the IO is to those slower USB
disks?  If yes then does lowering the dirty_bytes to something smaller
help?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C07E26B02B4
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 03:13:18 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id a77so7951383wma.12
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 00:13:18 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t100si6387909wrc.143.2017.06.01.00.13.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 00:13:17 -0700 (PDT)
Date: Thu, 1 Jun 2017 09:13:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [-next] memory hotplug regression
Message-ID: <20170601071310.GA32677@dhcp22.suse.cz>
References: <20170524082022.GC5427@osiris>
 <20170524083956.GC14733@dhcp22.suse.cz>
 <20170526122509.GB14849@osiris>
 <20170530121806.GD7969@dhcp22.suse.cz>
 <20170530123724.GC4874@osiris>
 <20170530143246.GJ7969@dhcp22.suse.cz>
 <20170530145501.GD4874@osiris>
 <20170531062439.GA3853@dhcp22.suse.cz>
 <20170601064954.GB7593@osiris>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170601064954.GB7593@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 01-06-17 08:49:54, Heiko Carstens wrote:
> On Wed, May 31, 2017 at 08:24:40AM +0200, Michal Hocko wrote:
> > > # cat /sys/devices/system/memory/memory16/valid_zones
> > > Normal Movable
> > > # echo online_movable > /sys/devices/system/memory/memory16/state
> > > # cat /sys/devices/system/memory/memory16/valid_zones
> > > Movable
> > > # cat /sys/devices/system/memory/memory18/valid_zones
> > > Movable
> > > # echo online > /sys/devices/system/memory/memory18/state
> > > # cat /sys/devices/system/memory/memory18/valid_zones
> > > Normal    <--- should be Movable
> > > # cat /sys/devices/system/memory/memory17/valid_zones
> > >           <--- no output
> > 
> > OK, so this is an independent problem and an unrelated one to the
> > patch I've posted. We need two patches actually. Damn, I hate
> > MMOP_ONLINE_KEEP. I will send 2 patches as a reply to this email.
> 
> Tested with your patches on top of linux-next as of yesterday, however
> starting at commit fa812e869a6fe7495a17150bb2639075081ef709 ("mm/zswap.c:
> delete an error message for a failed memory allocation in
> zswap_dstmem_prepare()"), since the "mm: per-lruvec slab stats" patch
> series breaks everything ;)
> 
> Tested-by: Heiko Carstens <heiko.carstens@de.ibm.com>

Thanks a lot for testing! I will post those patches for wider review
later today.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

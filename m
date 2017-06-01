Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9BD276B0279
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 02:50:02 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id g143so7834615wme.13
        for <linux-mm@kvack.org>; Wed, 31 May 2017 23:50:02 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l6si19254235ede.337.2017.05.31.23.50.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 May 2017 23:50:01 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v516nWp8079978
	for <linux-mm@kvack.org>; Thu, 1 Jun 2017 02:49:59 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2ata1msss3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Jun 2017 02:49:59 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Thu, 1 Jun 2017 07:49:57 +0100
Date: Thu, 1 Jun 2017 08:49:54 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [-next] memory hotplug regression
References: <20170524082022.GC5427@osiris>
 <20170524083956.GC14733@dhcp22.suse.cz>
 <20170526122509.GB14849@osiris>
 <20170530121806.GD7969@dhcp22.suse.cz>
 <20170530123724.GC4874@osiris>
 <20170530143246.GJ7969@dhcp22.suse.cz>
 <20170530145501.GD4874@osiris>
 <20170531062439.GA3853@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170531062439.GA3853@dhcp22.suse.cz>
Message-Id: <20170601064954.GB7593@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, May 31, 2017 at 08:24:40AM +0200, Michal Hocko wrote:
> > # cat /sys/devices/system/memory/memory16/valid_zones
> > Normal Movable
> > # echo online_movable > /sys/devices/system/memory/memory16/state
> > # cat /sys/devices/system/memory/memory16/valid_zones
> > Movable
> > # cat /sys/devices/system/memory/memory18/valid_zones
> > Movable
> > # echo online > /sys/devices/system/memory/memory18/state
> > # cat /sys/devices/system/memory/memory18/valid_zones
> > Normal    <--- should be Movable
> > # cat /sys/devices/system/memory/memory17/valid_zones
> >           <--- no output
> 
> OK, so this is an independent problem and an unrelated one to the
> patch I've posted. We need two patches actually. Damn, I hate
> MMOP_ONLINE_KEEP. I will send 2 patches as a reply to this email.

Tested with your patches on top of linux-next as of yesterday, however
starting at commit fa812e869a6fe7495a17150bb2639075081ef709 ("mm/zswap.c:
delete an error message for a failed memory allocation in
zswap_dstmem_prepare()"), since the "mm: per-lruvec slab stats" patch
series breaks everything ;)

Tested-by: Heiko Carstens <heiko.carstens@de.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

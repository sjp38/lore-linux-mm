Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id E6D7E6B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 11:12:05 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id b14so139839757wmb.1
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 08:12:05 -0800 (PST)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id j13si5135137wmd.85.2016.01.22.08.12.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jan 2016 08:12:04 -0800 (PST)
Received: by mail-wm0-f49.google.com with SMTP id n5so139746616wmn.0
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 08:12:04 -0800 (PST)
Date: Fri, 22 Jan 2016 17:12:02 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
Message-ID: <20160122161201.GC19465@dhcp22.suse.cz>
References: <569FAC90.5030407@oracle.com>
 <alpine.DEB.2.20.1601200954420.23983@east.gentwo.org>
 <20160120212806.GA26965@dhcp22.suse.cz>
 <alpine.DEB.2.20.1601201552590.26496@east.gentwo.org>
 <20160121082402.GA29520@dhcp22.suse.cz>
 <alpine.DEB.2.20.1601210941540.7063@east.gentwo.org>
 <20160121165148.GF29520@dhcp22.suse.cz>
 <alpine.DEB.2.20.1601211130580.7741@east.gentwo.org>
 <20160122140418.GB19465@dhcp22.suse.cz>
 <alpine.DEB.2.20.1601220950290.17929@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1601220950290.17929@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri 22-01-16 10:07:01, Christoph Lameter wrote:
> On Fri, 22 Jan 2016, Michal Hocko wrote:
> 
> > Wouldn't it be much more easier and simply get rid of the VM_BUG_ON?
> > What is the point of keeping it in the first place. The code can
> > perfectly cope with the race.
> 
> Ok then lets do that.

Could you repost the patch with the updated description?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

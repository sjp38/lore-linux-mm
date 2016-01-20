Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id A29B16B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 10:20:19 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id r129so135476096wmr.0
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 07:20:19 -0800 (PST)
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com. [74.125.82.44])
        by mx.google.com with ESMTPS id m204si41180227wmf.38.2016.01.20.07.20.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jan 2016 07:20:18 -0800 (PST)
Received: by mail-wm0-f44.google.com with SMTP id n5so34772467wmn.0
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 07:20:18 -0800 (PST)
Date: Wed, 20 Jan 2016 16:20:16 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm, vmstat: kernel BUG at mm/vmstat.c:1408!
Message-ID: <20160120152015.GI14187@dhcp22.suse.cz>
References: <5674A5C3.1050504@oracle.com>
 <20160120143719.GF14187@dhcp22.suse.cz>
 <alpine.DEB.2.20.1601200913250.21388@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1601200913250.21388@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed 20-01-16 09:14:06, Christoph Lameter wrote:
> On Wed, 20 Jan 2016, Michal Hocko wrote:
> 
> > [CCing Andrew]
> >
> > I am just reading through this old discussion again because "vmstat:
> > make vmstat_updater deferrable again and shut down on idle" which seems
> > to be the culprit AFAIU has been merged as 0eb77e988032 and I do not see
> > any follow up fix merged to linus tree
> 
> Is there any way to reproce this issue? This is running through trinity
> right? Can we please get the exact syscall that causes this to occur?

As per the backtrace in the initial report this seems to be time
dependent as the crash happens from _kthread_ context. So it doesn't
seem to be directly related to any particular syscall.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

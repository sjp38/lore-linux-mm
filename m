Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id B22F16B025E
	for <linux-mm@kvack.org>; Mon, 16 May 2016 07:16:29 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id m64so97262026lfd.1
        for <linux-mm@kvack.org>; Mon, 16 May 2016 04:16:29 -0700 (PDT)
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com. [74.125.82.54])
        by mx.google.com with ESMTPS id j124si19494376wmg.99.2016.05.16.04.16.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 May 2016 04:16:28 -0700 (PDT)
Received: by mail-wm0-f54.google.com with SMTP id n129so96900484wmn.1
        for <linux-mm@kvack.org>; Mon, 16 May 2016 04:16:28 -0700 (PDT)
Date: Mon, 16 May 2016 13:16:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: why the count nr_file_pages is not equal to nr_inactive_file +
 nr_active_file ?
Message-ID: <20160516111626.GG23146@dhcp22.suse.cz>
References: <573550D8.9030507@huawei.com>
 <dce01643-7aa9-e779-e4ac-b74439f5074d@intel.com>
 <573582DE.3030302@huawei.com>
 <20160516095720.GB23251@dhcp22.suse.cz>
 <57399A84.20205@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57399A84.20205@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Aaron Lu <aaron.lu@intel.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 16-05-16 18:01:40, Xishi Qiu wrote:
> On 2016/5/16 17:57, Michal Hocko wrote:
> 
> > [Sorry I haven't noticed this answer before]
> > 
> > On Fri 13-05-16 15:31:42, Xishi Qiu wrote:
> >> On 2016/5/13 15:00, Aaron Lu wrote:
> >>
> >> Hi Aaron,
> >>
> >> Thanks for your reply, but I find the count of nr_shmem is very small
> >> in my system.
> > 
> > which kernel version is this? I remember that we used to account thp
> > pages as NR_FILE_PAGE as well in the past.
> > 
> > I didn't get to look at your number more closely though.
> 
> Hi Michal,
> 
> It's android kernel, v3.10
> I think the thp config is off.

Ble. Not enough sleep. I didn't mean thp but hugetlb pages. Sorry about
the confusion. If even that is not the case then there is either an
accounting bug or some fs doesn't put pages in the pagecache directly to
the LRUs or thos pages are on unevictable list.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 092186B0038
	for <linux-mm@kvack.org>; Sat, 21 Mar 2015 04:11:18 -0400 (EDT)
Received: by pdbop1 with SMTP id op1so131077794pdb.2
        for <linux-mm@kvack.org>; Sat, 21 Mar 2015 01:11:17 -0700 (PDT)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com. [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id i5si13269229pde.37.2015.03.21.01.11.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 21 Mar 2015 01:11:17 -0700 (PDT)
Received: by pdbcz9 with SMTP id cz9so130991440pdb.3
        for <linux-mm@kvack.org>; Sat, 21 Mar 2015 01:11:16 -0700 (PDT)
Date: Fri, 20 Mar 2015 23:41:25 +0800
From: Wang YanQing <udknight@gmail.com>
Subject: Re: [RFC] Strange do_munmap in mmap_region
Message-ID: <20150320154125.GA3168@udknight>
References: <20150228064647.GA9550@udknight.ahead-top.com>
 <CALYGNiMLwhqQSmj58mT4MWk2RAuU-3TykoSd=XjuXVfqkL3NoA@mail.gmail.com>
 <20150319151214.GA2175@udknight>
 <CALYGNiPjEFLC2uiTGZMqP4TwDBit6+3VaiEpvGELYg8jDsVXBw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALYGNiPjEFLC2uiTGZMqP4TwDBit6+3VaiEpvGELYg8jDsVXBw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, yinghai@kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Thu, Mar 19, 2015 at 06:36:54PM +0300, Konstantin Khlebnikov wrote:
> > Assme process has vma in region 4096-8192, one page size, mapped to
> > a file's first 4096 bytes, then a new map want to create vma in range
> > 0-8192 to map 4096-1288 in file, please tell me what's your meaning:
> > "so everything what was here before is unmapped in process"?
> >
> > Why we can just delete old vma for first 4096 size in file which reside
> > in range 4096-8192 without notify user process? And create the new vma
> > to occupy range 0-8192, do you think "everything" is really the same?
> 
> Old and new vmas are intersects? Then that means userpace asked to
> create new mapping at fixed address, so it tells kernel to unmap
> everything in that range. Without MAP_FIXED kernel always choose free area.
> 

Thanks, Konstantin Khlebnikov, you cure my headache :)

I haven't notice MAP_FIXED.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

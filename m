Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0FC236B025E
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 07:28:14 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f126so11242547wma.3
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 04:28:14 -0700 (PDT)
Received: from mail.ud19.udmedia.de (ud19.udmedia.de. [194.117.254.59])
        by mx.google.com with ESMTPS id b131si19931682wmh.145.2016.07.12.04.28.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 04:28:12 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Tue, 12 Jul 2016 13:28:12 +0200
From: Matthias Dahl <ml_linux-kernel@binary-island.eu>
Subject: Re: Page Allocation Failures/OOM with dm-crypt on software RAID10
 (Intel Rapid Storage)
In-Reply-To: <20160712095013.GA14591@dhcp22.suse.cz>
References: <02580b0a303da26b669b4a9892624b13@mail.ud19.udmedia.de>
 <20160712095013.GA14591@dhcp22.suse.cz>
Message-ID: <d9dbe0328e938eb7544fdb2aa8b5a9c7@mail.ud19.udmedia.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-raid@vger.kernel.org, linux-mm@kvack.org, dm-devel@redhat.com, linux-kernel@vger.kernel.org

Hello Michal...

On 2016-07-12 11:50, Michal Hocko wrote:

> This smells like file pages are stuck in the writeback somewhere and 
> the
> anon memory is not reclaimable because you do not have any swap device.

Not having a swap device shouldn't be a problem -- and in this case, it
would cause even more trouble as in disk i/o.

What could cause the file pages to get stuck or stopped from being 
written
to the disk? And more importantly, what is so unique/special about the
Intel Rapid Storage that it happens (seemingly) exclusively with that
and not the the normal Linux s/w raid support?

Also, if the pages are not written to disk, shouldn't something error
out or slow dd down? Obviously dd is capable of copying zeros a lot
faster than they could ever be written to disk -- and still, it works
just fine without dm-crypt in-between. It is only when dm-crypt /is/
involved, that the memory gets filled up and things get out of control.

Thanks,
Matthias

-- 
Dipl.-Inf. (FH) Matthias Dahl | Software Engineer | binary-island.eu
  services: custom software [desktop, mobile, web], server administration

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 310B66B0261
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 08:13:09 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id q17so23331046lbn.3
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 05:13:09 -0700 (PDT)
Received: from mail-ph.de-nserver.de (mail-ph.de-nserver.de. [85.158.179.214])
        by mx.google.com with ESMTPS id xq9si329084wjb.161.2016.06.02.05.13.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 05:13:07 -0700 (PDT)
Subject: Re: shrink_active_list/try_to_release_page bug? (was Re: xfs trace in
 4.4.2 / also in 4.3.3 WARNING fs/xfs/xfs_aops.c:1232 xfs_vm_releasepage)
References: <20160516010602.GA24980@bfoster.bfoster>
 <57420A47.2000700@profihost.ag> <20160522213850.GE26977@dastard>
 <574BEA84.3010206@profihost.ag> <20160530223657.GP26977@dastard>
 <20160531010724.GA9616@bbox> <20160531025509.GA12670@dastard>
 <20160531035904.GA17371@bbox> <20160531060712.GC12670@dastard>
 <574D2B1E.2040002@profihost.ag> <20160531073119.GD12670@dastard>
From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Message-ID: <575022D2.7030502@profihost.ag>
Date: Thu, 2 Jun 2016 14:13:06 +0200
MIME-Version: 1.0
In-Reply-To: <20160531073119.GD12670@dastard>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Minchan Kim <minchan@kernel.org>, Brian Foster <bfoster@redhat.com>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


Am 31.05.2016 um 09:31 schrieb Dave Chinner:
> On Tue, May 31, 2016 at 08:11:42AM +0200, Stefan Priebe - Profihost AG wrote:
>>> I'm half tempted at this point to mostly ignore this mm/ behavour
>>> because we are moving down the path of removing buffer heads from
>>> XFS. That will require us to do different things in ->releasepage
>>> and so just skipping dirty pages in the XFS code is the best thing
>>> to do....
>>
>> does this change anything i should test? Or is 4.6 still the way to go?
> 
> Doesn't matter now - the warning will still be there on 4.6. I think
> you can simply ignore it as the XFS code appears to be handling the
> dirty page that is being passed to it correctly. We'll work out what
> needs to be done to get rid of the warning for this case, wether it
> be a mm/ change or an XFS change.

Any idea what i could do with 4.4.X? Can i safely remove the WARN_ONCE
statement?

Stefan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

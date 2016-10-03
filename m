Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 685C96B0069
	for <linux-mm@kvack.org>; Mon,  3 Oct 2016 13:35:26 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l138so99784955wmg.3
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 10:35:26 -0700 (PDT)
Received: from albireo.enyo.de (albireo.enyo.de. [5.158.152.32])
        by mx.google.com with ESMTPS id fe18si29697534wjc.241.2016.10.03.10.35.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Oct 2016 10:35:25 -0700 (PDT)
From: Florian Weimer <fw@deneb.enyo.de>
Subject: Re: Excessive xfs_inode allocations trigger OOM killer
References: <87a8f2pd2d.fsf@mid.deneb.enyo.de> <20160920203039.GI340@dastard>
	<87mvj2mgsg.fsf@mid.deneb.enyo.de> <20160920214612.GJ340@dastard>
	<20160921080425.GC10300@dhcp22.suse.cz>
	<878tuetvl6.fsf@mid.deneb.enyo.de>
	<20160926200209.GA23827@dhcp22.suse.cz>
Date: Mon, 03 Oct 2016 19:35:18 +0200
In-Reply-To: <20160926200209.GA23827@dhcp22.suse.cz> (Michal Hocko's message
	of "Mon, 26 Sep 2016 22:02:10 +0200")
Message-ID: <878tu5xrmx.fsf@mid.deneb.enyo.de>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dave Chinner <david@fromorbit.com>, xfs@oss.sgi.com, linux-xfs@vger.kernel.org, linux-mm@kvack.org

* Michal Hocko:

>> I'm not sure if I can reproduce this issue in a sufficiently reliable
>> way, but I can try.  (I still have not found the process which causes
>> the xfs_inode allocations go up.)
>> 
>> Is linux-next still the tree to test?
>
> Yes it contains all the compaction related fixes which we believe to
> address recent higher order OOMs.

I tried 4.7.5 instead.  I could not reproduce the issue so far there.
Thanks to whoever fixed it. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 15A1B6B2065
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 09:12:29 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id n95so70239qte.16
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 06:12:29 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n127si2966876qkf.230.2018.11.20.06.12.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 06:12:28 -0800 (PST)
Date: Tue, 20 Nov 2018 22:12:21 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: Memory hotplug softlock issue
Message-ID: <20181120141221.GA7386@MiWiFi-R3L-srv>
References: <20181119125121.GK22247@dhcp22.suse.cz>
 <20181119141016.GO22247@dhcp22.suse.cz>
 <20181119173312.GV22247@dhcp22.suse.cz>
 <alpine.LSU.2.11.1811191215290.15640@eggly.anvils>
 <20181119205907.GW22247@dhcp22.suse.cz>
 <20181120015644.GA5727@MiWiFi-R3L-srv>
 <alpine.LSU.2.11.1811192127130.2848@eggly.anvils>
 <3f1a82a8-f2aa-ac5e-e6a8-057256162321@suse.cz>
 <20181120135803.GA3369@MiWiFi-R3L-srv>
 <20181120140524.GI22247@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181120140524.GI22247@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, pifang@redhat.com, David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com, Mel Gorman <mgorman@suse.de>

On 11/20/18 at 03:05pm, Michal Hocko wrote:
> > Yes, I applied Hugh's patch 8 hours ago, then our QE Ping operated on
> > that machine, after many times of hot removing/adding, the endless
> > looping during mirgrating is not seen any more. The test result for
> > Hugh's patch is positive. I even suggested Ping increasing the memory
> > pressure to "stress -m 250", it still succeeded to offline and remove.
> > 
> > So I think this patch works to solve the issue. Thanks a lot for your
> > help, all of you. 
> 
> This is a great news! Thanks for your swift feedback. I will go and try
> to review Hugh's patch soon.

Yeah. Thanks a lot for your help on debugging and narrowing down
to position the cause of the issue, Michal, really appreciated!

> > Meanwhile we found sometime onlining page may not add back all memory
> > blocks on one memory board, then hot removing/adding them will cause
> > kernel panic. I will investigate further and collect information, see if
> > it's a kernel issue or udev issue.
> 
> It would be great to get a report in a new email thread.

Sure, will do after reproducing and inforamtion arranging.

Thanks
Baoquan

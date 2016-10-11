Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id E3D306B0069
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 03:10:16 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id x23so8114627lfi.0
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 00:10:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q4si2999056wjz.292.2016.10.11.00.10.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Oct 2016 00:10:15 -0700 (PDT)
Subject: Re: More OOM problems
References: <eafb59b5-0a2b-0e28-ca79-f044470a2851@Quantum.com>
 <20160930214448.GB28379@dhcp22.suse.cz>
 <982671bd-5733-0cd5-c15d-112648ff14c5@Quantum.com>
 <20161011064426.GA31996@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c71036ae-73db-f05a-fd14-fe2de44515b9@suse.cz>
Date: Tue, 11 Oct 2016 09:10:13 +0200
MIME-Version: 1.0
In-Reply-To: <20161011064426.GA31996@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>

On 10/11/2016 08:44 AM, Michal Hocko wrote:
> [Let's restore the CC list]
>
> On Mon 10-10-16 10:20:27, Ralf-Peter Rohbeck wrote:
>> I ran my torture test overnight (after finding the last linux-next branch
>> that compiled, sigh...):
>> Wrote two 4TB USB3 drives, compiled a kernel and ran my btrfs dedup script
>> in parallel.
>
> Thanks for testing and good to hear that premature OOMs are gone

Great indeed. Note that meanwhile the patches went to mainline so we'd 
definitely welcome testing from the rest of you who had originally problems with 
4.7/4.8 and didn't try the linux-next recently. So a good point would be to test 
4.9-rc1 when it's released. I hope you don't want to discover regressions again 
too late, in the 4.9 final release :)

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

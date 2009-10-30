Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 099F86B004D
	for <linux-mm@kvack.org>; Fri, 30 Oct 2009 11:13:27 -0400 (EDT)
Received: by bwz7 with SMTP id 7so3901509bwz.6
        for <linux-mm@kvack.org>; Fri, 30 Oct 2009 08:13:25 -0700 (PDT)
Message-ID: <4AEB0291.4080003@gmail.com>
Date: Fri, 30 Oct 2009 16:13:21 +0100
From: =?UTF-8?B?VmVkcmFuIEZ1cmHEjQ==?= <vedran.furac@gmail.com>
Reply-To: vedran.furac@gmail.com
MIME-Version: 1.0
Subject: Re: Memory overcommit
References: <hav57c$rso$1@ger.gmane.org> <alpine.DEB.2.00.0910291225460.27732@chino.kir.corp.google.com> <4AEAEFDD.5060009@gmail.com> <200910300808.38450.tfjellstrom@shaw.ca>
In-Reply-To: <200910300808.38450.tfjellstrom@shaw.ca>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: tfjellstrom@shaw.ca
Cc: linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

Thomas Fjellstrom wrote:

>> malloc: Cannot allocate memory /* Great, no OOM, but: */
>> 
>> % free -m total       used       free     shared    buffers cached
>> Mem:      3458        3429         29          0        102 1119
>> -/+ buffers/cache:    2207       1251
>> 
>> There's plenty of memory available. Shouldn't cache be 
>> automatically dropped (this question was in my original mail, hence
>>  the subject)?
>> 
> 
> I think this is the MOST serious issue related to the oom killer. For
> some reason it refuses to drop pages before trying to kill. When it
> should drop cache, THEN kill if needed.

This isn't about OOM, but situation when you turn off overcommit. I was
jumping to conclusion here. You can drop caches manually with:
# echo 1 > /proc/sys/vm/drop_caches

but you still get: "malloc: Cannot allocate memory" even if almost
nothing is cached:

        total       used       free     shared    buffers     cached
Mem:    3458       2210       1248          0          3          90
-/+ buffers/cache: 2116       1342

As for not dropping pages by kernel before killing, I don't know nothing
about it. It happens so fast and I never tried to measure it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

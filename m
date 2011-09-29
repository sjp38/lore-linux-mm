Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 098149000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 17:18:51 -0400 (EDT)
MIME-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 8bit
Date: Thu, 29 Sep 2011 17:18:18 -0400
From: Eric B Munson <emunson@mgebm.net>
Subject: Re: [PATCH 0/9] V2: idle page tracking / working set estimation
In-Reply-To: <CANN689H1G-USQYQrOTb47Hrc7KMjLdxkppYCDKsTUy5WhuRs7w@mail.gmail.com>
References: <1317170947-17074-1-git-send-email-walken@google.com>
 <20110929164319.GA3509@mgebm.net>
 <CANN689H1G-USQYQrOTb47Hrc7KMjLdxkppYCDKsTUy5WhuRs7w@mail.gmail.com>
Message-ID: <4186d5662b3fb21af1b45f8a335414d3@mgebm.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Balbir Singh <bsingharora@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Michael Wolf <mjwolf@us.ibm.com>

 On Thu, 29 Sep 2011 13:25:00 -0700, Michel Lespinasse wrote:
> On Thu, Sep 29, 2011 at 9:43 AM, Eric B Munson <emunson@mgebm.net> 
> wrote:
>> I have been trying to test these patches since yesterday afternoon. 
>> A When my
>> machine is idle, they behave fine. A I started looking at performance 
>> to make
>> sure they were a big regression by testing kernel builds with the 
>> scanner
>> disabled, and then enabled (set to 120 seconds). A The scanner 
>> disabled builds
>> work fine, but with the scanner enabled the second time I build my 
>> kernel hangs
>> my machine every time. A Unfortunately, I do not have any more 
>> information than
>> that for you at the moment. A My next step is to try the same tests 
>> in qemu to
>> see if I can get more state information when the kernel hangs.
>
> Could you please send me your .config file ? Also, did you apply the
> patches on top of straight v3.0 and what is your machine like ?
>
> Thanks,


 My .config will come separately to you.  I applied the patches to 
 Linus' master branch as of yesterday.  My machine is a single Xeon 5690 
 with 12G of ram (do you need more details than that?)

 Thanks,
 Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

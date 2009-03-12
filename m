Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 105FE6B004F
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 07:23:40 -0400 (EDT)
Received: by wf-out-1314.google.com with SMTP id 28so529955wfa.11
        for <linux-mm@kvack.org>; Thu, 12 Mar 2009 04:23:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090312094529.GA4335@balbir.in.ibm.com>
References: <20090312041414.GG23583@balbir.in.ibm.com>
	 <20090312131739.296785da.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090312164204.43B7.A69D9226@jp.fujitsu.com>
	 <20090312094529.GA4335@balbir.in.ibm.com>
Date: Thu, 12 Mar 2009 20:23:39 +0900
Message-ID: <2f11576a0903120423i56958bbbuc88cdd8cec5c9c17@mail.gmail.com>
Subject: Re: [BUGFIX][PATCH 1/5] memcg use correct scan number at reclaim
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

>> > IIUC, # of pages to be scanned is just determined once, here.
>>
>> In this case, lockless is right behavior.
>> lockless is valuable than precise ZSTAT. end user can't observe this race.
>>
>
> Lockless works fine provided the data is correctly aligned. I need to
> check this out more thoroghly.

Thanks a lot :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

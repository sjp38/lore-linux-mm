Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id B36FE6B0062
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 22:01:36 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id k14so2579285oag.14
        for <linux-mm@kvack.org>; Wed, 31 Oct 2012 19:01:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121101012546.GC26256@bbox>
References: <1351560594-18366-1-git-send-email-minchan@kernel.org>
 <20121031143524.0509665d.akpm@linux-foundation.org> <CAPM31RKm89s6PaAnfySUD-f+eGdoZP6=9DHy58tx_4Zi8Z9WPQ@mail.gmail.com>
 <CAHGf_=om34CQoPqgmVE5v8oVxntaJQ-bvFeEPMnfe_R+uvxqrQ@mail.gmail.com> <20121101012546.GC26256@bbox>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Wed, 31 Oct 2012 22:01:15 -0400
Message-ID: <CAHGf_=qm7HRLzhUHx7t3FmCAUmj0F7Vm6jaTGu_YwD+U-j58Aw@mail.gmail.com>
Subject: Re: [RFC v2] Support volatile range for anon vma
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Paul Turner <pjt@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Stultz <john.stultz@linaro.org>, Christoph Lameter <cl@linux.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, sanjay@google.com, David Rientjes <rientjes@google.com>

>> - making zero page daemon and avoid pagesize zero fill at page fault
>> - making new vma or page flags and mark as discardable w/o swap and
>>   vmscan treat it. (like this and/or MADV_FREE)
>
> Thanks for the information.
> I realized by you I'm not first people to think of this idea.
> Rik already tried it(https://lkml.org/lkml/2007/4/17/53) by new page flag
> and even other OSes already have such good feature. And John's concept was
> already tried long time ago (https://lkml.org/lkml/2005/11/1/384)
>
> Hmm, I look over Rik's thread but couldn't find why it wasn't merged
> at that time. Anyone know it?

Dunno. and I like volatile feature than old one. but bold remark, please don't
100% trust me, I haven't review a detailed code of your patch and I don't
strictly understand it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

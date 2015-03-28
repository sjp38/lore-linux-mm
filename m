Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f42.google.com (mail-oi0-f42.google.com [209.85.218.42])
	by kanga.kvack.org (Postfix) with ESMTP id E8C0A6B006E
	for <linux-mm@kvack.org>; Sat, 28 Mar 2015 08:04:15 -0400 (EDT)
Received: by oicf142 with SMTP id f142so86399479oic.3
        for <linux-mm@kvack.org>; Sat, 28 Mar 2015 05:04:15 -0700 (PDT)
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com. [209.85.218.49])
        by mx.google.com with ESMTPS id n9si2809972obm.70.2015.03.28.05.04.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 28 Mar 2015 05:04:15 -0700 (PDT)
Received: by oicf142 with SMTP id f142so86399396oic.3
        for <linux-mm@kvack.org>; Sat, 28 Mar 2015 05:04:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55169723.3070006@linaro.org>
References: <359c926bc85cdf79650e39f2344c2083002545bb.1427347966.git.viresh.kumar@linaro.org>
	<20150326131822.fce6609efdd85b89ceb3f61c@linux-foundation.org>
	<CAKohpo=nTXutbVVf-7iAwtgya4zUL686XbG69ExQ3Pi=VQRE-A@mail.gmail.com>
	<20150327091613.GE27490@worktop.programming.kicks-ass.net>
	<20150327093023.GA32047@worktop.ger.corp.intel.com>
	<CAOh2x=nbisppmuBwfLWndyCPKem1N_KzoTxyAYcQuL77T_bJfw@mail.gmail.com>
	<20150328095322.GH27490@worktop.programming.kicks-ass.net>
	<55169723.3070006@linaro.org>
Date: Sat, 28 Mar 2015 17:34:15 +0530
Message-ID: <CAKohpongCRxU_xV2BTnGeuKHRmSOd1mA_ARfhjYZkRs0MX_8vg@mail.gmail.com>
Subject: Re: [RFC] vmstat: Avoid waking up idle-cpu to service shepherd work
From: Viresh Kumar <viresh.kumar@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, vinmenon@codeaurora.org, shashim@codeaurora.org, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, dave@stgolabs.net, Konstantin Khlebnikov <koct9i@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Suresh Siddha <suresh.b.siddha@intel.com>, Thomas Gleixner <tglx@linutronix.de>

On 28 March 2015 at 17:27, viresh kumar <viresh.kumar@linaro.org> wrote:
> On 28 March 2015 at 15:23, Peter Zijlstra <peterz@infradead.org> wrote:
>
>> Well, for one your patch is indeed disgusting.
>
> Yeah, I agree :)

Sigh..

Sorry for the series of *nonsense* mails before the last one.

Its some thunderbird *BUG* which did that, I was accessing my
mail from both gmail's interface and thunderbird and somehow
this happened. I have hit the send button only once.

Really sorry for the noise.

(The last mail has few inquiries towards the end and a thanks note,
just to identify it..)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

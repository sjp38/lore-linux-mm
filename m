Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 5A9A36B0044
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 03:06:26 -0400 (EDT)
Message-ID: <4F9E39F1.5030600@kernel.org>
Date: Mon, 30 Apr 2012 16:06:25 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: vmevent: question?
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>


Hi Pekka,

I looked into vmevent and have few questions.

vmevent_smaple gathers all registered values to report to user if vmevent match.
But the time gap between vmevent match check and vmevent_sample_attr could make error
so user could confuse.

Q 1. Why do we report _all_ registered vmstat value?
     In my opinion, it's okay just to report _a_ value vmevent_match happens.
Q 2. Is it okay although value when vmevent_match check happens is different with
     vmevent_sample_attr in vmevent_sample's for loop?
     I think it's not good.
Q 3. Do you have any plan to change getting value's method?
     Now it's IRQ context so we have limitation to get a vmstat values so that
     It couldn't be generic. IMHO, To merge into mainline, we should solve this problem.
Q 4. Do you have any plan for this patchset to merge into mainline?

Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

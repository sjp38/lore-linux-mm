Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5A1386B0022
	for <linux-mm@kvack.org>; Tue, 10 May 2011 05:52:44 -0400 (EDT)
Message-ID: <4DC90AE8.101@parallels.com>
Date: Tue, 10 May 2011 13:52:40 +0400
From: Konstantin Khlebnikov <khlebnikov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] tmpfs: fix race between umount and writepage
References: <4DAFD0B1.9090603@parallels.com> <20110421064150.6431.84511.stgit@localhost6> <20110421124424.0a10ed0c.akpm@linux-foundation.org> <4DB0FE8F.9070407@parallels.com> <alpine.LSU.2.00.1105031223120.9845@sister.anvils> <4DC4D9A6.9070103@parallels.com> <alpine.LSU.2.00.1105071621330.3668@sister.anvils> <4DC691D0.6050104@parallels.com> <alpine.LSU.2.00.1105081234240.15963@sister.anvils>
In-Reply-To: <alpine.LSU.2.00.1105081234240.15963@sister.anvils>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hugh Dickins wrote:
> On Sun, 8 May 2011, Konstantin Khlebnikov wrote:
>>
>> Ok, I can test final patch-set on the next week.
>> Also I can try to add some swapoff test-cases.
>
> That would be helpful if you have the time: thank you.

I Confirm, patch 1/3 really fixes race between writepage and umount, as expected.

In patch 2/3: race-window between unlock_page and iput extremely small.
My test works fine in parallel with thirty random swapon-swapoff,
but it works without this patch too, thus I cannot catch this race.

I apply patch 3/3 too, but have not tested this case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

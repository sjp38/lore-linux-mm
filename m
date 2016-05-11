Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 329006B007E
	for <linux-mm@kvack.org>; Wed, 11 May 2016 07:18:11 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id yl2so57215908pac.2
        for <linux-mm@kvack.org>; Wed, 11 May 2016 04:18:11 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id t188si8960805pfb.245.2016.05.11.04.18.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 May 2016 04:18:10 -0700 (PDT)
Subject: Re: [PATCH 1/2] mmap.2: clarify MAP_LOCKED semantic
References: <1431527892-2996-1-git-send-email-miso@dhcp22.suse.cz>
 <1431527892-2996-2-git-send-email-miso@dhcp22.suse.cz>
 <57331275.9000805@infradead.org>
From: Peter Zijlstra <peterz@infradead.org>
Message-ID: <573314ED.4090704@infradead.org>
Date: Wed, 11 May 2016 13:18:05 +0200
MIME-Version: 1.0
In-Reply-To: <57331275.9000805@infradead.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <miso@dhcp22.suse.cz>, Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>



On 05/11/2016 01:07 PM, Peter Zijlstra wrote:
> On 05/13/2015 04:38 PM, Michal Hocko wrote:
>>
>> This patch makes the semantic of MAP_LOCKED explicit and suggest using
>> mmap + mlock as the only way to guarantee no later major page faults.
>>
>
> URGH, this really blows chunks. It basically means MAP_LOCKED is 
> pointless cruft and we might as well remove it.
>
> Why not fix it proper?

OK; after having been pointed at this discussion, it seems I reacted rather
too hasty in that I didn't read all the previous threads.

 From that it appears fixing this proper is indeed rather hard, and we 
should
indeed consider MAP_LOCKED broken. At which point I would've worded the
manpage update stronger, but alas.

Sorry for the noise.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

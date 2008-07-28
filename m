Received: by fg-out-1718.google.com with SMTP id 19so7379445fgg.4
        for <linux-mm@kvack.org>; Mon, 28 Jul 2008 10:19:47 -0700 (PDT)
Message-ID: <488DFFB0.1090107@gmail.com>
Date: Mon, 28 Jul 2008 19:19:44 +0200
From: Andrea Righi <righi.andrea@gmail.com>
Reply-To: righi.andrea@gmail.com
MIME-Version: 1.0
Subject: Re: [PATCH 1/1] mm: unify pmd_free() implementation
References: <alpine.LFD.1.10.0807280851130.3486@nehalem.linux-foundation.org> <488DF119.2000004@gmail.com> <20080729012656.566F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080729012656.566F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
>> yep! clear.
>>
>> Ok, in this case wouldn't be better at least to define pud_free() as:
>>
>> static inline pud_free(struct mm_struct *mm, pmd_t *pmd)
>> {
>> }
> 
> I also like this :)

ok, a simpler patch using the inline function will follow.

-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

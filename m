From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <16909246.1195259556869.kamezawa.hiroyu@jp.fujitsu.com>
Date: Sat, 17 Nov 2007 09:32:36 +0900 (JST)
Subject: Re: Re: page_referenced() and VM_LOCKED
In-Reply-To: <Pine.LNX.4.64.0711161749020.12201@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <Pine.LNX.4.64.0711161749020.12201@blonde.wat.veritas.com>
 <473D1BC9.8050904@google.com> <20071116144641.f12fd610.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ethan Solomita <solo@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> > I would've thought the point was to treat locked pages as active, never
>> > pushing them into the inactive list, but since that's not quite what's
>> > happening I was hoping someone could give me a clue.
>
>Rik and Lee and others have proposed that we keep VM_LOCKED pages
>off both active and inactive lists: that seems a better way forward.
>
agreed.

>> Then, "VM_LOCKED & not referenced" anon page is added to swap cache
>> (before pushed back to active list)
>> 
>> Seems intended ?
>
>Not intended, no.  Rather a waste of swap.  How about this patch?
>
seems nice. I'd like to do some test in the next week,

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

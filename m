Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m97BQ5Ru017774
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 7 Oct 2008 20:26:05 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id CB82E2AC02B
	for <linux-mm@kvack.org>; Tue,  7 Oct 2008 20:26:04 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D3B712C045
	for <linux-mm@kvack.org>; Tue,  7 Oct 2008 20:26:04 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BCE01DB803F
	for <linux-mm@kvack.org>; Tue,  7 Oct 2008 20:26:04 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1EC531DB8038
	for <linux-mm@kvack.org>; Tue,  7 Oct 2008 20:26:04 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH, RFC] shmat: introduce flag SHM_MAP_HINT
In-Reply-To: <20081007112119.GG20740@one.firstfloor.org>
References: <20081007195837.5A6B.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081007112119.GG20740@one.firstfloor.org>
Message-Id: <20081007202127.5A74.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  7 Oct 2008 20:26:03 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: kosaki.motohiro@jp.fujitsu.com, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Arjan van de Ven <arjan@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > Honestly, I don't like that qemu specific feature insert into shmem core.
> 
> I wouldn't say it's a qemu specific interface.  While qemu would 
> be the first user I would expect more in the future. It's a pretty
> obvious extension. In fact it nearly should be default, if the
> risk of breaking old applications wasn't too high.

hm, ok, i understand your intension.
however, I think following code isn't self describing.

	addr = shmat(shmid, addr, SHM_MAP_HINT);

because HINT is too generic word.
I think we should find better word.

SHM_MAP_NO_FIXED ?


In addision, I still think current patch has too poor description and too 
few comments.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

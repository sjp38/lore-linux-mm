Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 74AEE6B00A5
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 22:16:09 -0500 (EST)
Message-ID: <4ECDB6E6.40304@redhat.com>
Date: Thu, 24 Nov 2011 11:15:50 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [V3 PATCH 1/2] tmpfs: add fallocate support
References: <1322038412-29013-1-git-send-email-amwang@redhat.com> <CAHGf_=rOYkEGHakyHpihopMg2VtVfDV7XvC_QGs_kj6HgDmBRA@mail.gmail.com> <CAOJsxLH2foaRHYoPgRufu_J8B-YEvQ8aJNuQqHOPNj9YFvAubw@mail.gmail.com> <alpine.LSU.2.00.1111231407170.2573@sister.anvils>
In-Reply-To: <alpine.LSU.2.00.1111231407170.2573@sister.anvils>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Christoph Hellwig <hch@lst.de>, Dave Hansen <dave@linux.vnet.ibm.com>, Lennart Poettering <lennart@poettering.net>, Kay Sievers <kay.sievers@vrfy.org>, linux-mm@kvack.org

ao? 2011a1'11ae??24ae?JPY 06:20, Hugh Dickins a??e??:
> On Wed, 23 Nov 2011, Pekka Enberg wrote:
>>
>> Why do we need to undo anyway?
...
> Another answer would be: if fallocate() had been defined to return
> the length that has been successfully allocated (as write() returns
> the length written), then it would be reasonable to return partial
> length instead of failing with ENOSPC, and not undo.  But it was
> defined to return -1 on failure or 0 on success, so cannot report
> partial success.
>
> Another answer would be: if the disk is near full, it's not good
> for a fallocate() to fail with -ENOSPC while nonetheless grabbing
> all the remaining blocks; even worse if another fallocate() were
> racing with it.

Exactly, fallocate() should not make the bad situation even worse.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

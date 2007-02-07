Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id l171MfFL021135
	for <linux-mm@kvack.org>; Tue, 6 Feb 2007 17:22:41 -0800
Received: from ug-out-1314.google.com (ugfk3.prod.google.com [10.66.187.3])
	by zps38.corp.google.com with ESMTP id l171MaTg008628
	for <linux-mm@kvack.org>; Tue, 6 Feb 2007 17:22:36 -0800
Received: by ug-out-1314.google.com with SMTP id k3so52164ugf
        for <linux-mm@kvack.org>; Tue, 06 Feb 2007 17:22:35 -0800 (PST)
Message-ID: <b040c32a0702061722m2e32e05fo4a70c8f5173ccb43@mail.gmail.com>
Date: Tue, 6 Feb 2007 17:22:35 -0800
From: "Ken Chen" <kenchen@google.com>
Subject: Re: hugetlb: preserve hugetlb pte dirty state
In-Reply-To: <20070206170827.d9ec67a2.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <b040c32a0702061306l771d2b71s719cee7cf4713e71@mail.gmail.com>
	 <20070206163531.8d524171.akpm@linux-foundation.org>
	 <b040c32a0702061647k33c3354csc5d6b28ef3a102f7@mail.gmail.com>
	 <20070206170827.d9ec67a2.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/6/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> > yeah, I wonder why I didn't do that :-P  Especially after I asked you
> > a similar question the other day.  I will redo it and retest.
>
> No rush - the code should work OK as-is and given the total catastrophe
> which that change caused in core mm, making the same change to hugepages
> should be done with some care and thought and maintainer-poking.

OK.  That's comforting.  I was thinking along the same line that
hugetlb should be in-sync with core mm code and should continue to do
the same thing like core mm in the unmap path (to transfer dirty bit
into page struct); even if we dirty a page in the fault path and that
dirty state will be on for the life of the page.  I will play with the
fault path for a while then.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

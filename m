Received: by wf-out-1314.google.com with SMTP id 28so3642751wfc.11
        for <linux-mm@kvack.org>; Tue, 07 Oct 2008 09:31:06 -0700 (PDT)
Message-ID: <2f11576a0810070931k79eb72dfr838a96650563b93a@mail.gmail.com>
Date: Wed, 8 Oct 2008 01:31:05 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH, v3] shmat: introduce flag SHM_MAP_NOT_FIXED
In-Reply-To: <1223396117-8118-1-git-send-email-kirill@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1223396117-8118-1-git-send-email-kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@redhat.com>, Arjan van de Ven <arjan@infradead.org>, Hugh Dickins <hugh@veritas.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Ulrich Drepper <drepper@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> If SHM_MAP_NOT_FIXED specified and shmaddr is not NULL, then the kernel takes
> shmaddr as a hint about where to place the mapping. The address of the mapping
> is returned as the result of the call.
>
> It's similar to mmap() without MAP_FIXED.

ummm

Sorry, no.
This description still doesn't explain why this interface is needed.

The one of the points is this interface is used by another person or not.
You should explain how large this interface benefit has.

Andi kleen explained this interface _can_  be used another one.
but nobody explain who use it actually.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

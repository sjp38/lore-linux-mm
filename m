Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id l16LhaQX028995
	for <linux-mm@kvack.org>; Tue, 6 Feb 2007 21:43:36 GMT
Received: from wr-out-0506.google.com (wri71.prod.google.com [10.54.9.71])
	by spaceape14.eur.corp.google.com with ESMTP id l16Lh5nd012754
	for <linux-mm@kvack.org>; Tue, 6 Feb 2007 21:43:35 GMT
Received: by wr-out-0506.google.com with SMTP id 71so5085wri
        for <linux-mm@kvack.org>; Tue, 06 Feb 2007 13:43:35 -0800 (PST)
Message-ID: <b040c32a0702061343g53d852bau3524d168eae490fd@mail.gmail.com>
Date: Tue, 6 Feb 2007 13:43:26 -0800
From: "Ken Chen" <kenchen@google.com>
Subject: Re: hugetlb: preserve hugetlb pte dirty state
In-Reply-To: <29495f1d0702061336ra41f060id52db9a1a26d47aa@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <b040c32a0702061306l771d2b71s719cee7cf4713e71@mail.gmail.com>
	 <29495f1d0702061336ra41f060id52db9a1a26d47aa@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nish Aravamudan <nish.aravamudan@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/6/07, Nish Aravamudan <nish.aravamudan@gmail.com> wrote:
> This fixes my bug with HugePages_Rsvd going to 2^64 - 1.
> ("Hugepages_Rsvd goes huge in 2.6.20-rc7" is the subject on linux-mm).
> Stable material, too, I would say.

Wow, we hit the same bug in different ways, nice to hear that this
patch fixed the problem you observed.

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

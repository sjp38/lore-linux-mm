Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A7E836B00CB
	for <linux-mm@kvack.org>; Tue, 25 Aug 2009 17:24:28 -0400 (EDT)
Received: by an-out-0708.google.com with SMTP id c3so1341398ana.26
        for <linux-mm@kvack.org>; Tue, 25 Aug 2009 14:24:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090819100553.GE24809@csn.ul.ie>
References: <alpine.LFD.2.00.0908172317470.32114@casper.infradead.org>
	 <56e00de0908180329p2a37da3fp43ddcb8c2d63336a@mail.gmail.com>
	 <202cde0e0908182248we01324em2d24b9e741727a7b@mail.gmail.com>
	 <20090819100553.GE24809@csn.ul.ie>
Date: Mon, 24 Aug 2009 18:14:30 +1200
Message-ID: <202cde0e0908232314j4b90aa61pb4bcd0223ffbc087@mail.gmail.com>
Subject: Re: [PATCH 0/3]HTLB mapping for drivers (take 2)
From: Alexey Korolev <akorolex@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Eric Munson <linux-mm@mgebm.net>, Alexey Korolev <akorolev@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Mel,

> How about;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0o Extend Eric's helper slightly to take a GFP =
mask that is
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0associated with the inode and used for =
allocations from
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0outside the hugepage pool
> =C2=A0 =C2=A0 =C2=A0 =C2=A0o A helper that returns the page at a given of=
fset within
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0a hugetlbfs file for population before =
the page has been
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0faulted.
>
> I know this is a bit hand-wavy, but it would allow significant sharing
> of the existing code and remove much of the hugetlbfs-awareness from
> your current driver.
>

I'm trying to write the solution you have described. The question I
have is about extension of hugetlb_file_setup function.
Is it supposed to allocate memory in hugetlb_file_setup function? Or
it is supposed to have reservation only.
If reservation only, then it is necessary to keep a gfp_mask for a
file somewhere. Would it be Ok to keep a gfp_mask for a file in
file->private_data?

Thanks,
Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

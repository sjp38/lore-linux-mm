Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4EF7A6B004D
	for <linux-mm@kvack.org>; Sat, 10 Oct 2009 11:36:00 -0400 (EDT)
Received: by iwn5 with SMTP id 5so4212225iwn.11
        for <linux-mm@kvack.org>; Sat, 10 Oct 2009 08:35:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.1.10.0910090946220.26484@gentwo.org>
References: <20091009100527.1284.A69D9226@jp.fujitsu.com>
	 <20091009100708.1287.A69D9226@jp.fujitsu.com>
	 <20091009174505.12B3.A69D9226@jp.fujitsu.com>
	 <alpine.DEB.1.10.0910090946220.26484@gentwo.org>
Date: Sun, 11 Oct 2009 00:35:58 +0900
Message-ID: <2f11576a0910100835t4cba94a9v3ccd7473de229af5@mail.gmail.com>
Subject: Re: [PATCH 2/3] Fix memory leak of never putback pages in mbind()
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

>> Oops, I forgot to remove unnecessary brace.
>> updated patch is here.
>
> Thats a style issue. There are other weird things in do_mbind as well
> like starting a new block in the middle of another.
>
> Having
>
> }
> {
>
> in a program is a bit confusing. So could you do a cleanup patch for
> mpol_bind? Preferably it should make it easy to read to and bring some
> order to the confusing error handling.

Yes, I'll do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

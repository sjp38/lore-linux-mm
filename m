Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 944A86B004D
	for <linux-mm@kvack.org>; Sat, 12 Sep 2009 07:41:39 -0400 (EDT)
Received: by ywh28 with SMTP id 28so2713946ywh.15
        for <linux-mm@kvack.org>; Sat, 12 Sep 2009 04:41:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.64.0909121218020.488@sister.anvils>
References: <alpine.LRH.2.00.0908241110420.21562@tundra.namei.org>
	<Pine.LNX.4.64.0908241258070.27704@sister.anvils> <4A929BF5.2050105@gmail.com>
	<Pine.LNX.4.64.0908241532470.9322@sister.anvils> <8bd0f97a0909110703o4d496a45jddc0d7d6fd8674b4@mail.gmail.com>
	<Pine.LNX.4.64.0909121212560.488@sister.anvils> <Pine.LNX.4.64.0909121218020.488@sister.anvils>
From: Mike Frysinger <vapier.adi@gmail.com>
Date: Sat, 12 Sep 2009 07:41:22 -0400
Message-ID: <8bd0f97a0909120441y764174d3pc78929438492c6dd@mail.gmail.com>
Subject: Re: [PATCH] fix undefined reference to user_shm_unlock
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Stefan Huber <shuber2@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Meerwald <pmeerw@cosy.sbg.ac.at>, James Morris <jmorris@namei.org>, William Irwin <wli@movementarian.org>, Mel Gorman <mel@csn.ul.ie>, Ravikiran G Thirumalai <kiran@scalex86.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, Sep 12, 2009 at 07:21, Hugh Dickins wrote:
> My 353d5c30c666580347515da609dd74a2b8e9b828 "mm: fix hugetlb bug due to
> user_shm_unlock call" broke the CONFIG_SYSVIPC !CONFIG_MMU build of both
> 2.6.31 and 2.6.30.6: "undefined reference to `user_shm_unlock'".
>
> gcc didn't understand my comment! so couldn't figure out to optimize
> away user_shm_unlock() from the error path in the hugetlb-less case,
> as it does elsewhere. =C2=A0Help it to do so, in a language it understand=
s.

thanks, this works for me

> Cc: stable@kernel.org

should go into 2.6.30.7 and 2.6.31.1
-mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

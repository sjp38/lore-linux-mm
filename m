Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 33A1B6B0193
	for <linux-mm@kvack.org>; Sun, 14 Mar 2010 21:11:42 -0400 (EDT)
Received: by pwi4 with SMTP id 4so43586pwi.14
        for <linux-mm@kvack.org>; Sun, 14 Mar 2010 18:11:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1003141618001.32212@chino.kir.corp.google.com>
References: <1268567418-8700-1-git-send-email-user@bob-laptop>
	 <alpine.DEB.2.00.1003141618001.32212@chino.kir.corp.google.com>
Date: Mon, 15 Mar 2010 09:11:40 +0800
Message-ID: <cf18f8341003141811q187960cdwf15f27374064ab8d@mail.gmail.com>
Subject: Re: [PATCH] mempolicy: remove redundant code
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 15, 2010 at 7:18 AM, David Rientjes <rientjes@google.com> wrote=
:
> On Sun, 14 Mar 2010, Bob Liu wrote:
>
>> From: Bob Liu <lliubbo@gmail.com>
>>
>> 1. In funtion is_valid_nodemask(), varibable k will be inited to 0 in
>> the following loop, needn't init to policy_zone anymore.
>>
>> 2. (MPOL_F_STATIC_NODES | MPOL_F_RELATIVE_NODES) has already defined
>> to MPOL_MODE_FLAGS in mempolicy.h.
>
> Acked-by: David Rientjes <rientjes@google.com>
>
>> ---
>> =C2=A0mempolicy.c | =C2=A0 =C2=A05 +----
>> =C2=A01 files changed, 1 insertions(+), 4 deletions(-)
>>
>
> (although the diffstat still doesn't have the mm/ path).
>

Thanks a lot, I will check more careful next time :-)

--=20
Regards,
-Bob Liu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

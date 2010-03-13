Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B509C6B0161
	for <linux-mm@kvack.org>; Sat, 13 Mar 2010 00:03:49 -0500 (EST)
Received: by pxi34 with SMTP id 34so972920pxi.22
        for <linux-mm@kvack.org>; Fri, 12 Mar 2010 21:03:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1003121236060.13400@chino.kir.corp.google.com>
References: <cf18f8341003120224k243ff3fdq6d4a7acfe15dccc8@mail.gmail.com>
	 <alpine.DEB.2.00.1003121236060.13400@chino.kir.corp.google.com>
Date: Sat, 13 Mar 2010 13:03:48 +0800
Message-ID: <cf18f8341003122103i3164a28h4aea908507a6e12e@mail.gmail.com>
Subject: Re: [Patch] mempolicy: remove redundant code
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

On Sat, Mar 13, 2010 at 4:37 AM, David Rientjes <rientjes@google.com> wrote=
:
> On Fri, 12 Mar 2010, Bob Liu wrote:
>
>> 1. In funtion is_valid_nodemask(), varibable k will be inited to 0 in
>> the following loop, needn't init to policy_zone anymore.
>>
>> 2. (MPOL_F_STATIC_NODES | MPOL_F_RELATIVE_NODES) has already defined
>> to MPOL_MODE_FLAGS in mempolicy.h.
>>
>> Signed-off-by: Bob Liu <lliubbo@gmail.com>
>
> I like your patch, but it has whitespace damage. =C2=A0Would it be possib=
le to
> read the gmail section of Documentation/email-clients.txt and try to
> repropose it? =C2=A0Thanks.
>

I am sorry for that, I have resend that patch. Thanks a lot for your reply.

--=20
Regards,
-Bob Liu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

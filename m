Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6B5506B009B
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 14:05:33 -0500 (EST)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id oBGJ5UTT013388
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 11:05:30 -0800
Received: from qwk4 (qwk4.prod.google.com [10.241.195.132])
	by hpaq1.eem.corp.google.com with ESMTP id oBGJ5BOv001528
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 11:05:29 -0800
Received: by qwk4 with SMTP id 4so3717813qwk.32
        for <linux-mm@kvack.org>; Thu, 16 Dec 2010 11:05:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTim-WizK2PrfGM0zJ1=_VQkJao-D7oAcQ_et7-fi@mail.gmail.com>
References: <20101130194945.58962c44@xenia.leun.net>
	<alpine.LSU.2.00.1011301453090.12516@tigran.mtv.corp.google.com>
	<E1PNjsI-0005Bk-NB@pomaz-ex.szeredi.hu>
	<20101201124528.6809c539@xenia.leun.net>
	<E1PNqO1-0005px-9h@pomaz-ex.szeredi.hu>
	<20101202084159.6bff7355@xenia.leun.net>
	<20101202091552.4a63f717@xenia.leun.net>
	<E1PO5gh-00079U-Ma@pomaz-ex.szeredi.hu>
	<20101202115722.1c00afd5@xenia.leun.net>
	<20101203085350.55f94057@xenia.leun.net>
	<E1PPaIw-0004pW-Mk@pomaz-ex.szeredi.hu>
	<20101206204303.1de6277b@xenia.leun.net>
	<E1PRQDn-0007jZ-5S@pomaz-ex.szeredi.hu>
	<20101213142059.643f8080.akpm@linux-foundation.org>
	<E1PSSO8-0003sy-Vr@pomaz-ex.szeredi.hu>
	<alpine.LSU.2.00.1012142020030.12693@tigran.mtv.corp.google.com>
	<AANLkTim-WizK2PrfGM0zJ1=_VQkJao-D7oAcQ_et7-fi@mail.gmail.com>
Date: Thu, 16 Dec 2010 11:05:24 -0800
Message-ID: <AANLkTi=gbhxFGHj70ybCLU7exJ6ckLjzeFgjfQxTaGuQ@mail.gmail.com>
Subject: Re: kernel BUG at mm/truncate.c:475!
From: Hugh Dickins <hughd@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: =?UTF-8?B?Um9iZXJ0IMWad2nEmWNraQ==?= <robert@swiecki.net>
Cc: Miklos Szeredi <miklos@szeredi.hu>, Andrew Morton <akpm@linux-foundation.org>, lkml20101129@newton.leun.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Dec 16, 2010 at 6:50 AM, Robert =C5=9Awi=C4=99cki <robert@swiecki.n=
et> wrote:
>>
>> I'd feel rather happier about it if I thought it would also fix
>> Robert's kernel BUG at /build/buildd/linux-2.6.35/mm/filemap.c:128!
>> but I've still not found time to explain that one.
>>
>> Robert, you said yours is usually repeatable in 12 hours - any chance
>> you could give iknowthis a run with the patch below, to see if it
>> makes any difference to yours? =C2=A0(I admit I don't see how it would.)
>
> Hi Hugh,
>
> Do you still want me to do that?

If you can spare the time, yes, please do:
it will be valuable information either way.
I just don't want to deceive you that we
expect this to be the fix.

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

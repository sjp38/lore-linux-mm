Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8D34C8D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 11:08:12 -0500 (EST)
Received: from mail-iy0-f169.google.com (mail-iy0-f169.google.com [209.85.210.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p23G7gTu023876
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Thu, 3 Mar 2011 08:07:42 -0800
Received: by iyf13 with SMTP id 13so1402983iyf.14
        for <linux-mm@kvack.org>; Thu, 03 Mar 2011 08:07:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110303154706.GA22560@redhat.com>
References: <20110302162650.GA26810@redhat.com> <20110302162712.GB26810@redhat.com>
 <20110303114952.B94B.A69D9226@jp.fujitsu.com> <20110303154706.GA22560@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 3 Mar 2011 08:07:22 -0800
Message-ID: <AANLkTimp=mhedXLdrZFqK2QWYvg7MdmUPj3-Q9m2vtTx@mail.gmail.com>
Subject: Re: [PATCH v3 1/4] exec: introduce get_arg_ptr() helper
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, Milton Miller <miltonm@bga.com>

On Thu, Mar 3, 2011 at 7:47 AM, Oleg Nesterov <oleg@redhat.com> wrote:
>> I _personally_ don't like "conditional". Its name is based on code logic.
>> It's unclear what mean "conditional". From data strucuture view, It is
>> "opaque userland pointer".
>
> I agree with any naming, just suggest a better name ;)

Maybe just "struct user_arg_ptr" or something?

                        Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

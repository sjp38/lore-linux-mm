Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4AE848D003C
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 13:09:30 -0500 (EST)
Received: from mail-iy0-f169.google.com (mail-iy0-f169.google.com [209.85.210.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p22I8wrc010307
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 2 Mar 2011 10:08:59 -0800
Received: by iyf13 with SMTP id 13so221212iyf.14
        for <linux-mm@kvack.org>; Wed, 02 Mar 2011 10:08:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110302164428.GF26810@redhat.com>
References: <20101201182747.GB6143@redhat.com> <20110225175202.GA19059@redhat.com>
 <20110225175314.GD19059@redhat.com> <AANLkTik8epq5cx8n=k6ocMUfbg9kkUAZ8KL7ZiG4UuoU@mail.gmail.com>
 <20110226123731.GC4416@redhat.com> <AANLkTinFVCR_znYtyVuJcjFQq_fgMp+ozbSz54UKzvQ_@mail.gmail.com>
 <20110226174408.GA17442@redhat.com> <20110301204739.GA30406@redhat.com>
 <AANLkTikVecxcGoZ9a4hmkoi4wynrNfH9_AU7Vb+hOvbH@mail.gmail.com>
 <20110302162650.GA26810@redhat.com> <20110302164428.GF26810@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 2 Mar 2011 10:00:23 -0800
Message-ID: <AANLkTinzQmprg+XHKjTj7bA+jFf_N4hta3_09M+SEfRt@mail.gmail.com>
Subject: Re: [PATCH v3 0/4] exec: unify native/compat code
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, Milton Miller <miltonm@bga.com>

On Wed, Mar 2, 2011 at 8:44 AM, Oleg Nesterov <oleg@redhat.com> wrote:
>
> forgot to mention...
>
> And probably you meant we should pass "struct conditional_ptr*", not
> by value. I can redo again.

No, I think we're ok with passing the structure by value - it's a
small structure that would generally be passed in registers (at least
on some architectures, I guess it will depend on the ABI), and we do
the "struct-by-value" thing for other things too (notably the page
table entries), so it's not a new thing in the kernel.

So I think I finally have no complaints. Of course, I didn't actually
check whether it _works_, but I assume it does.

If the s390 people (who actually do special things with compat
pointers) can test, that would be ok, but I'm certainly happily going
to apply this series when the next merge window opens.

                            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id C50DB6B0062
	for <linux-mm@kvack.org>; Wed, 30 May 2012 16:10:56 -0400 (EDT)
Received: by ggm4 with SMTP id 4so257097ggm.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 13:10:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFzoVQ29C-AZYx=G62LErK+7HuTCpZhvovoyS0_KTGGZQg@mail.gmail.com>
References: <1338368529-21784-1-git-send-email-kosaki.motohiro@gmail.com> <CA+55aFzoVQ29C-AZYx=G62LErK+7HuTCpZhvovoyS0_KTGGZQg@mail.gmail.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Wed, 30 May 2012 16:10:35 -0400
Message-ID: <CAHGf_=p3b8FGaxoYfO_89yZTRZ4LdTxoeoBd=Fj0Ua0aLXvPGw@mail.gmail.com>
Subject: Re: [PATCH 0/6] mempolicy memory corruption fixlet
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@google.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, Christoph Lameter <cl@linux.com>, stable@vger.kernel.org, hughd@google.com

On Wed, May 30, 2012 at 2:26 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Wed, May 30, 2012 at 2:02 AM, =A0<kosaki.motohiro@gmail.com> wrote:
>>
>> So, I think we should reconsider about shared mempolicy completely.
>
> Quite frankly, I'd prefer that approach. The code is subtle and
> horribly bug-fraught, and I absolutely detest the way it looks too.
> Reading your patches was actually somewhat painful.

Oh, very sorry. I made effort to make smallest and simplest patches.
But I couldn't I do better. Current MPOL_F_SHARED is cra^H^H^H
complex. ;-)


> If we could just remove the support for it entirely, that would be
> *much* preferable to continue working with this code.
>
> Could we just try that removal, and see if anybody screams?

I'm keeping neutral a while and hope to hear other developers opinion.

Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

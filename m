Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B90AB6B007B
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 03:47:06 -0400 (EDT)
Received: by ywl5 with SMTP id 5so447663ywl.14
        for <linux-mm@kvack.org>; Thu, 16 Sep 2010 00:47:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100916155413.3BC0.A69D9226@jp.fujitsu.com>
References: <20100916145452.3BB1.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.1009152300380.25200@chino.kir.corp.google.com>
	<20100916155413.3BC0.A69D9226@jp.fujitsu.com>
Date: Thu, 16 Sep 2010 10:47:05 +0300
Message-ID: <AANLkTikyxAZBp63FxY26_MS6afDZO59r2FNoWF9W-GmT@mail.gmail.com>
Subject: Re: [PATCH 1/4] oom: remove totalpage normalization from oom_badness()
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, oss-security@lists.openwall.com, Solar Designer <solar@openwall.com>, Kees Cook <kees.cook@canonical.com>, Al Viro <viro@zeniv.linux.org.uk>, Oleg Nesterov <oleg@redhat.com>, Neil Horman <nhorman@tuxdriver.com>, linux-fsdevel@vger.kernel.org, pageexec@freemail.hu, Brad Spengler <spender@grsecurity.net>, Eugene Teo <eugene@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 16, 2010 at 9:57 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> On Thu, 16 Sep 2010, KOSAKI Motohiro wrote:
>>
>> > Current oom_score_adj is completely broken because It is strongly boun=
d
>> > google usecase and ignore other all.
>> >
>>
>> We've talked about this issue three times already. =A0The last two times
>> you've sent a revert patch, you failed to followup on the threads:
>>
>> =A0 =A0 =A0 http://marc.info/?t=3D128272938200002
>> =A0 =A0 =A0 http://marc.info/?t=3D128324705200002
>>
>> And now you've gone above Andrew, who is the maintainer of this code, an=
d
>> straight to Linus. =A0Between that and your failure to respond to my ans=
wers
>> to your questions, I'm really stunned at how unprofessional you've handl=
ed
>> this.
>
> Selfish must die. you failed to persuade to me. and I havgen't get anyone=
's objection.
> Then, I don't care your ugly whining.

I haven't followed the discussion at all so I hope you don't mind me
jumping in. Are there some real-world bug reports where OOM rewrite is
to blame? Why haven't those been fixed?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 98F5D6B0031
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 03:24:14 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id hq4so4879377wib.12
        for <linux-mm@kvack.org>; Wed, 03 Jul 2013 00:24:12 -0700 (PDT)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <20130702223714.GA28048@redhat.com>
References: <CA+icZUXo=Z4gDfCMvLqRQDq_fpNAq+UqtUw=jrU=3=kVZP-2+A@mail.gmail.com>
	<20130630181945.GA5171@redhat.com>
	<CA+icZUWLUSg-Sfd9FHXs8Amz+-s6vs_VOJsQpUSa9+fYM8XyNQ@mail.gmail.com>
	<20130702223714.GA28048@redhat.com>
Date: Wed, 3 Jul 2013 09:24:12 +0200
Message-ID: <CA+icZUWV+O9x7VUt9ocu3kk10vqDv3oEQ533mnsWhBiEKk7fJQ@mail.gmail.com>
Subject: Re: linux-next: Tree for Jun 28 [ BISECTED: rsyslog/imklog: High CPU
 usage ]
From: Sedat Dilek <sedat.dilek@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Daniel Vetter <daniel.vetter@ffwll.ch>, Imre Deak <imre.deak@intel.com>, Lukas Czerner <lczerner@redhat.com>, Samuel Ortiz <samuel@sortiz.org>, Wensong Zhang <wensong@linux-vs.org>, Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>, Ralf Baechle <ralf@linux-mips.org>, Valdis.Kletnieks@vt.edu, linux-mm <linux-mm@kvack.org>

On Wed, Jul 3, 2013 at 12:37 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> Hi Sedat,
>
> On 07/02, Sedat Dilek wrote:
>>
>> did you made a cleaned-up version?
>> AFAICS v3, I read that on linux-mm ML, sorry if I ask here in this thread.
>
> Yes, I am going to send v3 with this fix + another minor change.
> Sorry for delay, I was distracted, will try tomorrow.
>
> Besides, I think Andrew and Stephen need a rest before I try to
> break wait.h or the third time.
>

Everyone should get a 3rd chance :-).

BTW, dealing with such issues makes me more and more familiar with my
Linux-systems.

- Sedat -

> Oleg.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

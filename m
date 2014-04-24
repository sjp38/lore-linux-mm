Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f53.google.com (mail-oa0-f53.google.com [209.85.219.53])
	by kanga.kvack.org (Postfix) with ESMTP id 630EB6B0036
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 13:21:42 -0400 (EDT)
Received: by mail-oa0-f53.google.com with SMTP id j17so2964861oag.40
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 10:21:42 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id sm4si4034813obb.130.2014.04.24.10.21.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 24 Apr 2014 10:21:41 -0700 (PDT)
Message-ID: <1398360099.2744.8.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH 5/4] ipc,shm: minor cleanups
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Thu, 24 Apr 2014 10:21:39 -0700
In-Reply-To: <53589E8E.1040000@gmail.com>
References: <1398090397-2397-1-git-send-email-manfred@colorfullife.com>
		 <1398221636.6345.9.camel@buesod1.americas.hpqcorp.net>
		 <53574AA5.1060205@gmail.com>
	 <1398230745.27667.2.camel@buesod1.americas.hpqcorp.net>
	 <53589E8E.1040000@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Manfred Spraul <manfred@colorfullife.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, gthelen@google.com, aswin@hp.com, linux-mm@kvack.org

On Thu, 2014-04-24 at 07:18 +0200, Michael Kerrisk (man-pages) wrote:
> On 04/23/2014 07:25 AM, Davidlohr Bueso wrote:
> > On Wed, 2014-04-23 at 07:07 +0200, Michael Kerrisk (man-pages) wrote:
> >> On 04/23/2014 04:53 AM, Davidlohr Bueso wrote:
> >>> -  Breakup long function names/args.
> >>> -  Cleaup variable declaration.
> >>> -  s/current->mm/mm
> >>>
> >>> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> >>> ---
> >>>  ipc/shm.c | 40 +++++++++++++++++-----------------------
> >>>  1 file changed, 17 insertions(+), 23 deletions(-)
> >>>
> >>> diff --git a/ipc/shm.c b/ipc/shm.c
> >>> index f000696..584d02e 100644
> >>> --- a/ipc/shm.c
> >>> +++ b/ipc/shm.c
> >>> @@ -480,15 +480,13 @@ static const struct vm_operations_struct shm_vm_ops = {
> >>>  static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
> >>>  {
> >>>  	key_t key = params->key;
> >>> -	int shmflg = params->flg;
> >>> +	int id, error, shmflg = params->flg;
> >>
> >> It's largely a matter of taste (and I may be in a minority), and I know
> >> there's certainly precedent in the kernel code, but I don't much like the 
> >> style of mixing variable declarations that have initializers, with other
> >> unrelated declarations (e.g., variables without initializers). What is 
> >> the gain? One less line of text? That's (IMO) more than offset by the 
> >> small loss of readability.
> > 
> > Yes, it's taste. And yes, your in the minority, at least in many core
> > kernel components and ipc.
> 
> Davidlohr,
> 
> So, noting that the minority is less small than we thought, I'll just
> add this: I'd have appreciated it if your reply had been less 
> dismissive, and you'd actually responded to my concrete point about 
> loss of readability.

Apologies, I didn't mean to sound dismissive. It's just that I don't
like arguing over this kind of things. The idea of the cleanups wasn't
"lets remove LoC", but more "lets make the style suck less" -- and
believe me, ipc code is pretty darn ugly wrt. Over the last few months
we've improved it some, but still so much horror. The changes I make are
aligned with the general coding style we have in the rest of the kernel,
but yes, ultimately it comes down to taste.

Anyway, I am in favor of single line declarations with initializers
which are *meaningful*. The variables I moved around are not.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

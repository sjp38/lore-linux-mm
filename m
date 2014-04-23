Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 03B496B0037
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 18:27:58 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id r10so1211149pdi.2
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 15:27:58 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id qf5si1407057pac.88.2014.04.23.15.27.57
        for <linux-mm@kvack.org>;
        Wed, 23 Apr 2014 15:27:57 -0700 (PDT)
Date: Wed, 23 Apr 2014 15:27:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 5/4] ipc,shm: minor cleanups
Message-Id: <20140423152755.7f323cfd0e6901a2907afca8@linux-foundation.org>
In-Reply-To: <1398230745.27667.2.camel@buesod1.americas.hpqcorp.net>
References: <1398090397-2397-1-git-send-email-manfred@colorfullife.com>
	<1398221636.6345.9.camel@buesod1.americas.hpqcorp.net>
	<53574AA5.1060205@gmail.com>
	<1398230745.27667.2.camel@buesod1.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>, Manfred Spraul <manfred@colorfullife.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, gthelen@google.com, aswin@hp.com, linux-mm@kvack.org

On Tue, 22 Apr 2014 22:25:45 -0700 Davidlohr Bueso <davidlohr@hp.com> wrote:

> On Wed, 2014-04-23 at 07:07 +0200, Michael Kerrisk (man-pages) wrote:
> > On 04/23/2014 04:53 AM, Davidlohr Bueso wrote:
> > > -  Breakup long function names/args.
> > > -  Cleaup variable declaration.
> > > -  s/current->mm/mm
> > > 
> > > Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> > > ---
> > >  ipc/shm.c | 40 +++++++++++++++++-----------------------
> > >  1 file changed, 17 insertions(+), 23 deletions(-)
> > > 
> > > diff --git a/ipc/shm.c b/ipc/shm.c
> > > index f000696..584d02e 100644
> > > --- a/ipc/shm.c
> > > +++ b/ipc/shm.c
> > > @@ -480,15 +480,13 @@ static const struct vm_operations_struct shm_vm_ops = {
> > >  static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
> > >  {
> > >  	key_t key = params->key;
> > > -	int shmflg = params->flg;
> > > +	int id, error, shmflg = params->flg;
> > 
> > It's largely a matter of taste (and I may be in a minority), and I know
> > there's certainly precedent in the kernel code, but I don't much like the 
> > style of mixing variable declarations that have initializers, with other
> > unrelated declarations (e.g., variables without initializers). What is 
> > the gain? One less line of text? That's (IMO) more than offset by the 
> > small loss of readability.
> 
> Yes, it's taste. And yes, your in the minority, at least in many core
> kernel components and ipc.

I'm with Michael.

- Putting multiple definitions on the same line (whether or not they
  are initialized there) makes it impossible to add little comments
  documenting them.  And we need more little comments documenting
  locals.

- Having multiple definitions on the same line is maddening when the
  time comes to resolve patch conflicts.  And it increases the
  likelihood of conflicts in the first place.

- It makes it much harder to *find* a definition.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

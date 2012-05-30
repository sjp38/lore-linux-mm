Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 74E476B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 14:34:25 -0400 (EDT)
Date: Wed, 30 May 2012 13:34:21 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/6] mempolicy memory corruption fixlet
In-Reply-To: <CA+55aFzoVQ29C-AZYx=G62LErK+7HuTCpZhvovoyS0_KTGGZQg@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1205301328550.31768@router.home>
References: <1338368529-21784-1-git-send-email-kosaki.motohiro@gmail.com> <CA+55aFzoVQ29C-AZYx=G62LErK+7HuTCpZhvovoyS0_KTGGZQg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: kosaki.motohiro@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@google.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, stable@vger.kernel.org, hughd@google.com, sivanich@sgi.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, andi@firstfloor.org

On Wed, 30 May 2012, Linus Torvalds wrote:

> On Wed, May 30, 2012 at 2:02 AM,  <kosaki.motohiro@gmail.com> wrote:
> >
> > So, I think we should reconsider about shared mempolicy completely.
>
> Quite frankly, I'd prefer that approach. The code is subtle and
> horribly bug-fraught, and I absolutely detest the way it looks too.
> Reading your patches was actually somewhat painful.

It is so bad mostly because the integration of shared memory policies with
cpusets is not really working. Using either in isolation is ok especially
shared mempolicies do not play well with cpusets.

> If we could just remove the support for it entirely, that would be
> *much* preferable to continue working with this code.

Well shm support needs memory policies to spread data across nodes etc.
AFAICT support was put in due to requirements to support large database
vendors (oracle). Andi?

Its not going to be easy to remove.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

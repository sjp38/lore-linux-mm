Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 74CC86B005D
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 16:20:52 -0400 (EDT)
Date: Wed, 15 Aug 2012 13:20:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/6][resend] mempolicy memory corruption fixlet
Message-Id: <20120815132050.12f4dec4.akpm@linux-foundation.org>
In-Reply-To: <CA+5PVA7YejzbWDEpX=gj8s2QAQtgoxyNUUa5HhGtVGY+2BHqRA@mail.gmail.com>
References: <1339406250-10169-1-git-send-email-kosaki.motohiro@gmail.com>
	<CA+5PVA4CE0kwD1FmV=081wfCObVYe5GFYBQFO9_kVL4JWJBqpA@mail.gmail.com>
	<50201BB5.9050005@jp.fujitsu.com>
	<CA+5PVA7YejzbWDEpX=gj8s2QAQtgoxyNUUa5HhGtVGY+2BHqRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Boyer <jwboyer@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, kosaki.motohiro@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, davej@redhat.com, mgorman@suse.de, cl@linux.com, stable@vger.kernel.org

On Wed, 15 Aug 2012 07:40:46 -0400
Josh Boyer <jwboyer@gmail.com> wrote:

> >> I don't see these patches queued anywhere.  They aren't in linux-next,
> >> mmotm, or Linus' tree.  Did these get dropped?  Is the revert still
> >> needed?
> >
> > Sorry. my fault. yes, it is needed. currently, Some LTP was fail since
> > Mel's "mm: mempolicy: Let vma_merge and vma_split handle vma->vm_policy linkages" patch.
> 
> The series still isn't queued anywhere.  Are you planning on resending
> it again, or should it get picked up in a particular tree?

The patches need a refresh and a retest please, including incorporation
of Christoph's changelog modifications.

And for gawd's sake, please stop using my google address!  It messes me
all up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

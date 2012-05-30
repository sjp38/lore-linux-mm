Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id D64566B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 15:04:12 -0400 (EDT)
Received: by wibhr14 with SMTP id hr14so124330wib.8
        for <linux-mm@kvack.org>; Wed, 30 May 2012 12:04:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1205301328550.31768@router.home>
References: <1338368529-21784-1-git-send-email-kosaki.motohiro@gmail.com>
 <CA+55aFzoVQ29C-AZYx=G62LErK+7HuTCpZhvovoyS0_KTGGZQg@mail.gmail.com> <alpine.DEB.2.00.1205301328550.31768@router.home>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 30 May 2012 12:03:50 -0700
Message-ID: <CA+55aFztNx+pzmEtEDanuvT7mx5=csAQ_pUXzMJHG1yyu81Tzg@mail.gmail.com>
Subject: Re: [PATCH 0/6] mempolicy memory corruption fixlet
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: kosaki.motohiro@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@google.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, stable@vger.kernel.org, hughd@google.com, sivanich@sgi.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, andi@firstfloor.org

On Wed, May 30, 2012 at 11:34 AM, Christoph Lameter <cl@linux.com> wrote:
>
> Well shm support needs memory policies to spread data across nodes etc.
> AFAICT support was put in due to requirements to support large database
> vendors (oracle). Andi?
>
> Its not going to be easy to remove.

Ok. So can the people involved with this please review this patch-set
and comment on this one? I think it needs a bit of language editing
for the commit commentary, and I'd like it to see a *lot * of ack's
from the relevant vm people.

Please?

                      Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

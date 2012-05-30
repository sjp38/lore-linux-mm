Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id CCC816B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 14:27:03 -0400 (EDT)
Received: by wgbdt14 with SMTP id dt14so84385wgb.26
        for <linux-mm@kvack.org>; Wed, 30 May 2012 11:27:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1338368529-21784-1-git-send-email-kosaki.motohiro@gmail.com>
References: <1338368529-21784-1-git-send-email-kosaki.motohiro@gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 30 May 2012 11:26:41 -0700
Message-ID: <CA+55aFzoVQ29C-AZYx=G62LErK+7HuTCpZhvovoyS0_KTGGZQg@mail.gmail.com>
Subject: Re: [PATCH 0/6] mempolicy memory corruption fixlet
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@google.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, Christoph Lameter <cl@linux.com>, stable@vger.kernel.org, hughd@google.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Wed, May 30, 2012 at 2:02 AM,  <kosaki.motohiro@gmail.com> wrote:
>
> So, I think we should reconsider about shared mempolicy completely.

Quite frankly, I'd prefer that approach. The code is subtle and
horribly bug-fraught, and I absolutely detest the way it looks too.
Reading your patches was actually somewhat painful.

If we could just remove the support for it entirely, that would be
*much* preferable to continue working with this code.

Could we just try that removal, and see if anybody screams?

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id B51D06B0081
	for <linux-mm@kvack.org>; Wed, 16 May 2012 14:19:45 -0400 (EDT)
Date: Wed, 16 May 2012 12:51:30 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] mm: Fix slab->page _count corruption.
In-Reply-To: <CALnjE+pbsS3W8G7yN82fdnchmXDxGkTo+Gy2b4kj6DkuQ=Z+wQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1205161251001.25603@router.home>
References: <1337034597-1826-1-git-send-email-pshelar@nicira.com> <CALnjE+pbsS3W8G7yN82fdnchmXDxGkTo+Gy2b4kj6DkuQ=Z+wQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pravin Shelar <pshelar@nicira.com>
Cc: penberg@kernel.org, mpm@selenic.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jesse@nicira.com, abhide@nicira.com

On Wed, 16 May 2012, Pravin Shelar wrote:

> Can you comment on this patch. I have changed it according to your comments.

Looks fine to me.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

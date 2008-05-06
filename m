Subject: Re: [PATCH] mm/cgroup.c add error check
From: Andi Kleen <andi@firstfloor.org>
References: <20080506195216.4A6D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Date: Tue, 06 May 2008 14:43:48 +0200
In-Reply-To: <20080506195216.4A6D.KOSAKI.MOTOHIRO@jp.fujitsu.com> (KOSAKI Motohiro's message of "Tue, 06 May 2008 20:02:44 +0900")
Message-ID: <87wsm7bo1n.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> writes:

> on heavy workload, call_usermodehelper() may failure
> because it use kzmalloc(GFP_ATOMIC).

Better just fix it to not use GFP_ATOMIC in the first place.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

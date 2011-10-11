Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 487846B002D
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 15:35:35 -0400 (EDT)
From: Satoru Moriya <satoru.moriya@hds.com>
Date: Tue, 11 Oct 2011 15:32:11 -0400
Subject: RE: [PATCH -v2 -mm] add extra free kbytes tunable
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9CB516CBC4@USINDEVS02.corp.hds.com>
References: <20110901105208.3849a8ff@annuminas.surriel.com>
	<20110901100650.6d884589.rdunlap@xenotime.net>
	<20110901152650.7a63cb8b@annuminas.surriel.com>
	<alpine.DEB.2.00.1110072001070.13992@chino.kir.corp.google.com>
 <20111010153723.6397924f.akpm@linux-foundation.org>
In-Reply-To: <20111010153723.6397924f.akpm@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>, Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Seiji Aguchi <saguchi@redhat.com>, "hughd@google.com" <hughd@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On 10/10/2011 06:37 PM, Andrew Morton wrote:
> On Fri, 7 Oct 2011 20:08:19 -0700 (PDT) David Rientjes=20
> <rientjes@google.com> wrote:
>=20
>> On Thu, 1 Sep 2011, Rik van Riel wrote:
>
> The page allocator already tries harder if the caller has=20
> rt_task(current).  Why is this inadequate?  Can we extend this idea=20
> further to fix whatever-the-problem-is?

Actually page allocator decreases min watermark to 3/4 * min watermark
for rt-task. But in our case some applications create a lot of
processes and if all of them are rt-task, the amount of watermark
bonus(1/4 * min watermark) is not enough.

If we can tune the amount of bonus, it may be fine. But that is
almost all same as extra free kbytes.

> Does there exist anything like a test case which demonstrates the need=20
> for this feature?

Unfortunately I don't have a real test case but just simple one.
And in my simple test case, I can avoid direct reclaim if we set
workload as rt-task.

The simple test case I used is following:
http://marc.info/?l=3Dlinux-mm&m=3D131605773321672&w=3D2

Regards,
Satoru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

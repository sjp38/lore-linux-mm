Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id B2E926B002C
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 16:23:37 -0400 (EDT)
From: Satoru Moriya <satoru.moriya@hds.com>
Date: Tue, 11 Oct 2011 16:23:22 -0400
Subject: RE: [PATCH -v2 -mm] add extra free kbytes tunable
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9CB516CBFE@USINDEVS02.corp.hds.com>
References: <20110901105208.3849a8ff@annuminas.surriel.com>
	<20110901100650.6d884589.rdunlap@xenotime.net>
	<20110901152650.7a63cb8b@annuminas.surriel.com>
	<alpine.DEB.2.00.1110072001070.13992@chino.kir.corp.google.com>
	<20111010153723.6397924f.akpm@linux-foundation.org>
	<65795E11DBF1E645A09CEC7EAEE94B9CB516CBC4@USINDEVS02.corp.hds.com>
 <20111011125419.2702b5dc.akpm@linux-foundation.org>
In-Reply-To: <20111011125419.2702b5dc.akpm@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Seiji Aguchi <saguchi@redhat.com>, "hughd@google.com" <hughd@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On 10/11/2011 03:55 PM, Andrew Morton wrote:
> On Tue, 11 Oct 2011 15:32:11 -0400
> Satoru Moriya <satoru.moriya@hds.com> wrote:
>=20
>> On 10/10/2011 06:37 PM, Andrew Morton wrote:
>>> On Fri, 7 Oct 2011 20:08:19 -0700 (PDT) David Rientjes=20
>>> <rientjes@google.com> wrote:
>>>
>>>> On Thu, 1 Sep 2011, Rik van Riel wrote:
>>
>> Actually page allocator decreases min watermark to 3/4 * min=20
>> watermark for rt-task. But in our case some applications create a lot=20
>> of processes and if all of them are rt-task, the amount of watermark
>> bonus(1/4 * min watermark) is not enough.
>>
>> If we can tune the amount of bonus, it may be fine. But that is=20
>> almost all same as extra free kbytes.
>=20
> This situation is detectable at runtime.  If realtime tasks are being=20
> stalled in the page allocator then start to increase the free-page=20
> reserves.  A little control system.

Detecting at runtime is too late for some latency critical systems.
At that system, we must avoid a stall before it happens.

Also, if we increase the free-page reserves a.k.a min_free_kbytes,
the possibility of direct reclaim on other workloads increases.
I think it's a bad side effect.

Thanks,
Satoru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

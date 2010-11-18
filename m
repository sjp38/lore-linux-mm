Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A98D56B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 12:29:27 -0500 (EST)
Received: from mail-yw0-f41.google.com (mail-yw0-f41.google.com [209.85.213.41])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id oAIHSuFE029429
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 09:28:56 -0800
Received: by ywi6 with SMTP id 6so6404ywi.14
        for <linux-mm@kvack.org>; Thu, 18 Nov 2010 09:28:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101118114902.GJ8135@csn.ul.ie>
References: <patchbomb.1288798055@v2.random> <fc2579c9bddbfcf78d72.1288798060@v2.random>
 <20101118114902.GJ8135@csn.ul.ie>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 18 Nov 2010 09:28:27 -0800
Message-ID: <AANLkTik9U_r7tqdDYw24xwTgvp5c740Z9eMQeh8y4Hpi@mail.gmail.com>
Subject: Re: [PATCH 05 of 66] compound_lock
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 18, 2010 at 3:49 AM, Mel Gorman <mel@csn.ul.ie> wrote:
>> +
>> +static inline void compound_lock_irqsave(struct page *page,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0unsigned long *flagsp)
>> +{
>> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>> + =A0 =A0 unsigned long flags;
>> + =A0 =A0 local_irq_save(flags);
>> + =A0 =A0 compound_lock(page);
>> + =A0 =A0 *flagsp =3D flags;
>> +#endif
>> +}
>> +
>
> The pattern for spinlock irqsave passes in unsigned long, not unsigned
> long *. It'd be nice if they matched.

Indeed. Just make the thing return the flags the way the normal
spin_lock_irqsave() function does.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

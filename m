Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id D0EDA6B0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2013 13:27:37 -0400 (EDT)
Received: by mail-ve0-f176.google.com with SMTP id c13so6220484vea.7
        for <linux-mm@kvack.org>; Wed, 10 Jul 2013 10:27:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130710015936.GC13855@redhat.com>
References: <51DCBE24.3030406@gmail.com>
	<20130710015936.GC13855@redhat.com>
Date: Wed, 10 Jul 2013 13:27:36 -0400
Message-ID: <CAJzLF9=vWCd2JZTNG0dX4YmLAc=B05x-+bZgU0RaSZCaR5D38g@mail.gmail.com>
Subject: Re: [REGRESSION] x86 vmalloc issue from recent 3.10.0+ commit
From: "Michael L. Semon" <mlsemon35@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, "Michael L. Semon" <mlsemon35@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, d.hatayama@jp.fujitsu.com, akpm@linux-foundation.org

Thanks.  I'll re-review this, anyway, and re-bisect if time allows.
The kernel/SGI-XFS combo pulled last night did much better in this
regard.  The problem is down to a different and single backtrace about
vmalloc, and the PC is controllable now.  The old git was moved to a
different folder, though, in case it's still needed.

Michael

On Tue, Jul 9, 2013 at 9:59 PM, Dave Jones <davej@redhat.com> wrote:
> On Tue, Jul 09, 2013 at 09:51:32PM -0400, Michael L. Semon wrote:
>
>  > kernel: [ 2580.395592] vmap allocation for size 20480 failed: use vmalloc=<size> to increase size.
>  > kernel: [ 2580.395761] vmalloc: allocation failure: 16384 bytes
>
> I was seeing a lot of these recently too.
> (Though I also saw memory corruption afterwards possibly caused by
>  a broken fallback path somewhere when that vmalloc fails)
>
> http://comments.gmane.org/gmane.linux.kernel.mm/102895
>
>         Dave
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

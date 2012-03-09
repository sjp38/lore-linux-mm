Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 5D07F6B0044
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 14:41:22 -0500 (EST)
Received: by ghrr18 with SMTP id r18so1391106ghr.14
        for <linux-mm@kvack.org>; Fri, 09 Mar 2012 11:41:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120307144643.GB2009@x61.redhat.com>
References: <20120305181041.GA9829@x61.redhat.com>
	<4F56ECE6.4010100@gmail.com>
	<alpine.DEB.2.00.1203062142290.6424@chino.kir.corp.google.com>
	<20120307144643.GB2009@x61.redhat.com>
Date: Fri, 9 Mar 2012 21:41:21 +0200
Message-ID: <CAOJsxLFQjV1c7nQZMA2voybN0AdhGrKFN5svQHC2C=oP3vOD4g@mail.gmail.com>
Subject: Re: [PATCH -v2] mm: SLAB Out-of-memory diagnostics
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: David Rientjes <rientjes@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Randy Dunlap <rdunlap@xenotime.net>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Josef Bacik <josef@redhat.com>

On Wed, Mar 7, 2012 at 4:46 PM, Rafael Aquini <aquini@redhat.com> wrote:
>> > Nitpick:
>> >
>> > What about "node: 0" instead of "node0: " ?
>> >
>>
>> Good catch, that format would match the output of the slub out-of-memory
>> messages.
>>
>
> To be honest, I really don't see a big advantage on the nitpick, however,=
 if we
> want to accurately copycat the slub output here, I can insert a blank spa=
ce
> between the word and the digit, like the following:
> =A0 "node #: ..."

So if you're interested in getting this patch to v3.4, now would be a
good time to update the patch as per review comments and resend.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

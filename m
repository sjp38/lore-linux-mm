Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 465946B0044
	for <linux-mm@kvack.org>; Sat, 28 Apr 2012 09:05:39 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so1225334ghr.14
        for <linux-mm@kvack.org>; Sat, 28 Apr 2012 06:05:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120427160919.086dff9d.akpm@linux-foundation.org>
References: <4F998FDE.5020104@redhat.com> <CAHGf_=qLX7gofwHoSKpHLp7nvD6qJtHbmYzAR0UQ42JbfnYerw@mail.gmail.com>
 <20120427160919.086dff9d.akpm@linux-foundation.org>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Sat, 28 Apr 2012 09:05:16 -0400
Message-ID: <CAHGf_=o5+Tk_jdDxSQv4qZpaktV=ukhj=jospW9GDY7qqeVYow@mail.gmail.com>
Subject: Re: [PATCH -mm V3] do_migrate_pages() calls migrate_to_node() even if
 task is already on a correct node
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: lwoodman@redhat.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux.com>, Motohiro Kosaki <mkosaki@redhat.com>

2012/4/27 Andrew Morton <akpm@linux-foundation.org>:
> On Thu, 26 Apr 2012 21:14:16 -0400
> KOSAKI Motohiro <kosaki.motohiro@gmail.com> wrote:
>
>> From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
>> Cc: Motohiro Kosaki <mkosaki@redhat.com>
>> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>
> umm, help. =A0What is your preferred email address ;)

Now I'm using gmail address, but I'm still using fujitsu.com address for
patch signing. Because of, 1) identification from folks and 2) keep easier
making statistics. so then, in short,  jp.fujitsu.com please. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

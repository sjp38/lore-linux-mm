Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id E2C116B0044
	for <linux-mm@kvack.org>; Tue, 27 Mar 2012 23:43:01 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so615748ghr.14
        for <linux-mm@kvack.org>; Tue, 27 Mar 2012 20:43:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120327151238.302a5920.akpm@linux-foundation.org>
References: <1332805767-2013-1-git-send-email-consul.kautuk@gmail.com>
	<20120327151238.302a5920.akpm@linux-foundation.org>
Date: Wed, 28 Mar 2012 09:13:00 +0530
Message-ID: <CAFPAmTR67R6aF9U7-idXGDsbfvhTxEn=D3pu_Jjhq37rhcez8Q@mail.gmail.com>
Subject: Re: [PATCH 1/1] mmap.c: find_vma: remove if(mm) check
From: Kautuk Consul <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Al Viro <viro@zeniv.linux.org.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Mar 28, 2012 at 3:42 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Mon, 26 Mar 2012 19:49:27 -0400
> Kautuk Consul <consul.kautuk@gmail.com> wrote:
>
>> find_vma is called from kernel code where it is absolutely
>> sure that the mm_struct arg being passed to it is non-NULL.
>>
>> Remove the if(mm) check.
>
> It's odd that the if(mm) test exists - I wonder why it was originally
> added. =A0My repo only goes back ten years, and it's there in 2.4.18.
>
> Any code which calls find_vma() without an mm is surely pretty busted?
>
>
> Still, I think I'd prefer to do
>
> =A0 =A0 =A0 =A0if (WARN_ON_ONCE(!mm))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;
>

yes, I agree. that is safe for now as there are a huge number of calls
to this API.

> then let that bake for a kernel release, just to find out if we have a
> weird caller out there, such as a function which is called by both user
> threads and by kernel threads.

ok. I'll spin another one and send it to you with your suggestions in a day=
 or
two when I go back home after my day job.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 7E8CC6B0068
	for <linux-mm@kvack.org>; Tue,  7 May 2013 20:51:09 -0400 (EDT)
Received: by mail-qe0-f48.google.com with SMTP id 9so745934qea.7
        for <linux-mm@kvack.org>; Tue, 07 May 2013 17:51:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHGf_=ofADKRCgDN5Tanx4PyvoJFF9r=cHYMd+VRc=N3=4FGuA@mail.gmail.com>
References: <1367967522-3934-1-git-send-email-j.glisse@gmail.com>
	<CAHGf_=ofADKRCgDN5Tanx4PyvoJFF9r=cHYMd+VRc=N3=4FGuA@mail.gmail.com>
Date: Tue, 7 May 2013 20:51:08 -0400
Message-ID: <CAH3drwbt_YX-jWrwsp0X2CH3t9ms65fX40cvumr4FyRhKBcbyw@mail.gmail.com>
Subject: Re: [PATCH] mm: honor FOLL_GET flag in follow_hugetlb_page v2
From: Jerome Glisse <j.glisse@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Jerome Glisse <jglisse@redhat.com>

On Tue, May 7, 2013 at 8:47 PM, KOSAKI Motohiro
<kosaki.motohiro@gmail.com> wrote:
> On Tue, May 7, 2013 at 6:58 PM,  <j.glisse@gmail.com> wrote:
>> From: Jerome Glisse <jglisse@redhat.com>
>>
>> Do not increase page count if FOLL_GET is not set. None of the
>> current user can trigger the issue because none of the current
>> user call __get_user_pages with both the pages array ptr non
>> NULL and the FOLL_GET flags non set in other word all caller
>> of __get_user_pages that don't set the FOLL_GET flags also call
>> with pages == NULL.
>
> Because, __get_user_pages() doesn't allow pages==NULL and FOLL_GET is on.

Yes but this allow pages != NULL and FOLL_GET not set and as i said
there is no such user of that yet and this is exactly what i was
trying to use.

Cheers,
Jerome

>
> long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
> {
> (snip)
>     VM_BUG_ON(!!pages != !!(gup_flags & FOLL_GET));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

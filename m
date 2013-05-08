Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id EBD0E6B0068
	for <linux-mm@kvack.org>; Tue,  7 May 2013 20:47:29 -0400 (EDT)
Received: by mail-ob0-f171.google.com with SMTP id v19so1199841obq.2
        for <linux-mm@kvack.org>; Tue, 07 May 2013 17:47:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1367967522-3934-1-git-send-email-j.glisse@gmail.com>
References: <1367967522-3934-1-git-send-email-j.glisse@gmail.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Tue, 7 May 2013 20:47:08 -0400
Message-ID: <CAHGf_=ofADKRCgDN5Tanx4PyvoJFF9r=cHYMd+VRc=N3=4FGuA@mail.gmail.com>
Subject: Re: [PATCH] mm: honor FOLL_GET flag in follow_hugetlb_page v2
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Jerome Glisse <jglisse@redhat.com>

On Tue, May 7, 2013 at 6:58 PM,  <j.glisse@gmail.com> wrote:
> From: Jerome Glisse <jglisse@redhat.com>
>
> Do not increase page count if FOLL_GET is not set. None of the
> current user can trigger the issue because none of the current
> user call __get_user_pages with both the pages array ptr non
> NULL and the FOLL_GET flags non set in other word all caller
> of __get_user_pages that don't set the FOLL_GET flags also call
> with pages == NULL.

Because, __get_user_pages() doesn't allow pages==NULL and FOLL_GET is on.


long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
{
(snip)
    VM_BUG_ON(!!pages != !!(gup_flags & FOLL_GET));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

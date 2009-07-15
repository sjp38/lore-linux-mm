Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 704E86B004F
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 21:54:39 -0400 (EDT)
Received: by an-out-0708.google.com with SMTP id c3so1741356ana.26
        for <linux-mm@kvack.org>; Tue, 14 Jul 2009 19:30:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <983c694e0907141702t39bebefdr4024720f0a6dc4e1@mail.gmail.com>
References: <983c694e0907141702t39bebefdr4024720f0a6dc4e1@mail.gmail.com>
Date: Wed, 15 Jul 2009 14:30:18 +1200
Message-ID: <202cde0e0907141930j6b59e8fdn84e2c21c43e7b12f@mail.gmail.com>
Subject: Re: __get_free_pages page count increment
From: Alexey Korolev <akorolex@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: omar ramirez <or.rmz1@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

About two months ago I faced pretty much the same issue.
Yes it is a proper behaviour. Please see thread
http://marc.info/?l=3Dlinux-mm&m=3D124348722701100&w=3D2

The best solution for your case  would be involving split_page() function.

Thanks
Alexey

On Wed, Jul 15, 2009 at 12:02 PM, omar ramirez<or.rmz1@gmail.com> wrote:
> Hi,
>
> I have been digging about __get_free_pages function, and wanted to now
> why only the first page reserved with this function increments the
> page count and for the other they are marked as 0.
>
> So here it is what I'm doing, I'm reserving a chunk of pages (using
> __get_free_pages) in a display driver, then I pass that through
> userspace to a dsp driver to decode a video file and return the buffer
> to display.
>
> The buffer is mapped in the dsp, which also follows the get_page
> approach but it goes page-by-page on the buffer, incrementing the page
> count for all of the pages (so now first page count from the buffer
> will be 2 <display, dsp>, but for the rest it will be 1 <dsp>).
>
> The issue comes once those pages are unmapped from the dsp driver,
> because it will do a page_cache_release on all the reserved pages
> (which leave the count as it was before, first page 1 <display> and
> the rest as 0).
>
> This will throw the BUG: bad page state error because the count is
> being marked as 0 for the process using that buffer.
>
> So my question is, is it ok that the page count is NOT incremented for
> all but first page of __get_free_pages?
>
> Thanks in advance,
>
> omar
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

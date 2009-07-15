Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 52E0A6B004D
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 16:26:25 -0400 (EDT)
Received: by ewy11 with SMTP id 11so1884558ewy.38
        for <linux-mm@kvack.org>; Wed, 15 Jul 2009 13:26:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <202cde0e0907141930j6b59e8fdn84e2c21c43e7b12f@mail.gmail.com>
References: <983c694e0907141702t39bebefdr4024720f0a6dc4e1@mail.gmail.com>
	 <202cde0e0907141930j6b59e8fdn84e2c21c43e7b12f@mail.gmail.com>
Date: Wed, 15 Jul 2009 15:26:30 -0500
Message-ID: <983c694e0907151326q55390aa6of73e08c69fe297f0@mail.gmail.com>
Subject: Re: __get_free_pages page count increment
From: omar ramirez <or.rmz1@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Alexey Korolev <akorolex@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Jul 14, 2009 at 9:30 PM, Alexey Korolev<akorolex@gmail.com> wrote:
> Hi,
>
> About two months ago I faced pretty much the same issue.
> Yes it is a proper behaviour. Please see thread
> http://marc.info/?l=3Dlinux-mm&m=3D124348722701100&w=3D2
>
> The best solution for your case =A0would be involving split_page() functi=
on.
>

Thanks for the quick reply it really helped a lot!

-omar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 261646B01F0
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 21:31:03 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id o7S1Uxog015639
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 18:30:59 -0700
Received: from gxk10 (gxk10.prod.google.com [10.202.11.10])
	by wpaz37.hot.corp.google.com with ESMTP id o7S1UwdT015077
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 18:30:58 -0700
Received: by gxk10 with SMTP id 10so1590890gxk.23
        for <linux-mm@kvack.org>; Fri, 27 Aug 2010 18:30:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTin6+nHOowdptW2jaxg9urn3OLf9ArgGzKjWnQLM@mail.gmail.com>
References: <1282867897-31201-1-git-send-email-yinghan@google.com>
	<AANLkTimaLBJa9hmufqQy3jk7GD-mJDbg=Dqkaja0nOMk@mail.gmail.com>
	<AANLkTi=xUMSZ7wX-2BtJ0-+2BYLCTW=VPTAErinb5Zd2@mail.gmail.com>
	<AANLkTinP_q7S4_O921hdBoedmTp-7gw0+=4DPHZGmysi@mail.gmail.com>
	<AANLkTin6+nHOowdptW2jaxg9urn3OLf9ArgGzKjWnQLM@mail.gmail.com>
Date: Fri, 27 Aug 2010 18:30:58 -0700
Message-ID: <AANLkTin92hywGThE=Z7=ZJOJrmw4yA-d-sFCnUYxS2hd@mail.gmail.com>
Subject: Re: [PATCH] vmscan: fix missing place to check nr_swap_pages.
From: Venkatesh Pallipadi <venki@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 27, 2010 at 9:35 AM, Ying Han <yinghan@google.com> wrote:
> On Thu, Aug 26, 2010 at 10:00 PM, Minchan Kim <minchan.kim@gmail.com> wro=
te:
>>
>> On Fri, Aug 27, 2010 at 12:31 PM, Ying Han <yinghan@google.com> wrote:
>> > On Thu, Aug 26, 2010 at 6:03 PM, Minchan Kim <minchan.kim@gmail.com> w=
rote:
>> >>
>> >> Hello.
>> >>
>> >> On Fri, Aug 27, 2010 at 9:11 AM, Ying Han <yinghan@google.com> wrote:
>> >> > Fix a missed place where checks nr_swap_pages to do shrink_active_l=
ist. Make the
>> >> > change that moves the check to common function inactive_anon_is_low=

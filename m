Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5C2B26B0010
	for <linux-mm@kvack.org>; Wed, 14 Sep 2011 17:02:48 -0400 (EDT)
Received: by ywe9 with SMTP id 9so2290561ywe.14
        for <linux-mm@kvack.org>; Wed, 14 Sep 2011 14:02:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAC9WiBjbWTRBkRN6pKSqJLVJXzcx89j7oFpCf0dzVeHAJM8zyw@mail.gmail.com>
References: <1315941562-25422-1-git-send-email-sjenning@linux.vnet.ibm.com>
	<a7d17e7e-c6a1-448e-b60f-b79a4ae0c3ba@default>
	<CAC9WiBjbWTRBkRN6pKSqJLVJXzcx89j7oFpCf0dzVeHAJM8zyw@mail.gmail.com>
Date: Wed, 14 Sep 2011 23:02:45 +0200
Message-ID: <CAC9WiBiHZ8jSBRaFQdsk-DwaNLFyR=e0zWUgrNEu6mE0ZoS0vQ@mail.gmail.com>
Subject: Re: [PATCH] staging: zcache: fix cleancache crash
From: Francis Moreau <francis.moro@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, gregkh@suse.de, devel@driverdev.osuosl.org, linux-mm@kvack.org, ngupta@vflare.org, linux-kernel@vger.kernel.org

On Wed, Sep 14, 2011 at 11:26 AM, Francis Moreau <francis.moro@gmail.com> w=
rote:
> On Tue, Sep 13, 2011 at 10:56 PM, Dan Magenheimer
> <dan.magenheimer@oracle.com> wrote:
>>> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
>>> Sent: Tuesday, September 13, 2011 1:19 PM
>>> To: gregkh@suse.de
>>> Cc: devel@driverdev.osuosl.org; linux-mm@kvack.org; ngupta@vflare.org; =
linux-kernel@vger.kernel.org;
>>> francis.moro@gmail.com; Dan Magenheimer; Seth Jennings
>>> Subject: [PATCH] staging: zcache: fix cleancache crash
>>>
>>> After commit, c5f5c4db, cleancache crashes on the first
>>> successful get. This was caused by a remaining virt_to_page()
>>> call in zcache_pampd_get_data_and_free() that only gets
>>> run in the cleancache path.
>>>
>>> The patch converts the virt_to_page() to struct page
>>> casting like was done for other instances in c5f5c4db.
>>>
>>> Based on 3.1-rc4
>>>
>>> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
>>
>> Yep, this appears to fix it! =A0Hopefully Francis can confirm.
>
> Ok I can give this a try and let you know.

This patch has fixed the issue I was hitting with qemu.

Thanks
--=20
Francis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

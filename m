Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E643C8D0039
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 06:15:26 -0500 (EST)
Received: by gyd10 with SMTP id 10so536529gyd.14
        for <linux-mm@kvack.org>; Fri, 21 Jan 2011 03:15:25 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110121103850.GI13235@n2100.arm.linux.org.uk>
References: <1295516739-9839-1-git-send-email-pullip.cho@samsung.com>
	<1295544047.9039.609.camel@nimitz>
	<20110120180146.GH6335@n2100.arm.linux.org.uk>
	<AANLkTimsL8YfSdXCBpN2cNVpj8HeJF0f-A7MJQoie+Zm@mail.gmail.com>
	<20110121103850.GI13235@n2100.arm.linux.org.uk>
Date: Fri, 21 Jan 2011 20:15:24 +0900
Message-ID: <AANLkTi=8DnGVJ6j4rHv+bQoTK2UhgMysC95LuKjH-fBy@mail.gmail.com>
Subject: Re: [PATCH] ARM: mm: Regarding section when dealing with meminfo
From: KyongHo Cho <pullip.cho@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Kukjin Kim <kgene.kim@samsung.com>, KeyYoung Park <keyyoung.park@samsung.com>, linux-kernel@vger.kernel.org, Ilho Lee <ilho215.lee@samsung.com>, linux-mm@kvack.org, linux-samsung-soc@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 21, 2011 at 7:38 PM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Fri, Jan 21, 2011 at 11:12:27AM +0900, KyongHo Cho wrote:
>> Since the size of section is 256 mib and NR_BANKS is defined as 8,
>> no ARM system can have more RAM than 2GiB in the current implementation.
>> If you want banks in meminfo not to cross sparsemem boundaries,
>> we need to find another way of physical memory specification in the kern=
el.
>
> There is no problem with increasing NR_BANKS.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-samsung-s=
oc" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
I think it is not reasonable to split a contiguous physical memory
into several chunks.
9 banks are required to use 2 gib.
Even though you think it is no problem,
it becomes a problem when we want to give physical memory information
via booting command line but atag
because there is a restriction in number of characters in booting command l=
ine.

I don't understand why larger bank size than the section size is problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

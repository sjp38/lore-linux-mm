Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2DB778D0069
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 21:12:39 -0500 (EST)
Received: by ywj3 with SMTP id 3so426035ywj.14
        for <linux-mm@kvack.org>; Thu, 20 Jan 2011 18:12:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110120180146.GH6335@n2100.arm.linux.org.uk>
References: <1295516739-9839-1-git-send-email-pullip.cho@samsung.com>
	<1295544047.9039.609.camel@nimitz>
	<20110120180146.GH6335@n2100.arm.linux.org.uk>
Date: Fri, 21 Jan 2011 11:12:27 +0900
Message-ID: <AANLkTimsL8YfSdXCBpN2cNVpj8HeJF0f-A7MJQoie+Zm@mail.gmail.com>
Subject: Re: [PATCH] ARM: mm: Regarding section when dealing with meminfo
From: KyongHo Cho <pullip.cho@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Kukjin Kim <kgene.kim@samsung.com>, KeyYoung Park <keyyoung.park@samsung.com>, linux-kernel@vger.kernel.org, Ilho Lee <ilho215.lee@samsung.com>, linux-mm@kvack.org, linux-samsung-soc@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 21, 2011 at 3:01 AM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Thu, Jan 20, 2011 at 09:20:47AM -0800, Dave Hansen wrote:
>> This problem actually exists without sparsemem, too. =A0Discontigmem (at
>> least) does it as well.
>
> We don't expect banks to cross sparsemem boundaries, or the older
> discontigmem nodes (esp. as we used to store the node number.)
> Discontigmem support has been removed now so that doesn't apply
> anymore.
>

Our system can have 3 GiB of RAM in maximum.
In the near future, ARM APs can have up to 1 TiB with LPAE.

Since the size of section is 256 mib and NR_BANKS is defined as 8,
no ARM system can have more RAM than 2GiB in the current implementation.
If you want banks in meminfo not to cross sparsemem boundaries,
we need to find another way of physical memory specification in the kernel.

>> The x86 version of show_mem() actually manages to do this without any
>> #ifdefs, and works for a ton of configuration options. =A0It uses
>> pfn_valid() to tell whether it can touch a given pfn.
>
> x86 memory layout tends to be very simple as it expects memory to
> start at the beginning of every region described by a pgdat and extend
> in one contiguous block. =A0I wish ARM was that simple.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

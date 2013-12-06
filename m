Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 888E86B0055
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 09:57:13 -0500 (EST)
Received: by mail-qc0-f172.google.com with SMTP id e16so531284qcx.17
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 06:57:13 -0800 (PST)
Received: from g5t0006.atlanta.hp.com (g5t0006.atlanta.hp.com. [15.192.0.43])
        by mx.google.com with ESMTPS id k6si52812459qej.14.2013.12.06.06.57.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 06 Dec 2013 06:57:12 -0800 (PST)
Message-ID: <1386341536.1791.283.camel@misato.fc.hp.com>
Subject: Re: [PATCH] mm, x86: Skip NUMA_NO_NODE while parsing SLIT
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 06 Dec 2013 07:52:16 -0700
In-Reply-To: <52A17B83.8060601@jp.fujitsu.com>
References: <1386191348-4696-1-git-send-email-toshi.kani@hp.com>
	  <52A054A0.6060108@jp.fujitsu.com>
	 <1386256309.1791.253.camel@misato.fc.hp.com>
	 <52A17B83.8060601@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, mingo@kernel.org, hpa@zytor.com, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org

On Fri, 2013-12-06 at 16:23 +0900, Yasuaki Ishimatsu wrote:
> (2013/12/06 0:11), Toshi Kani wrote:
> > On Thu, 2013-12-05 at 19:25 +0900, Yasuaki Ishimatsu wrote:
> >> (2013/12/05 6:09), Toshi Kani wrote:
> >>> When ACPI SLIT table has an I/O locality (i.e. a locality unique
> >>> to an I/O device), numa_set_distance() emits the warning message
> >>> below.
> >>>
> >>>    NUMA: Warning: node ids are out of bound, from=-1 to=-1 distance=10
> >>>
> >>> acpi_numa_slit_init() calls numa_set_distance() with pxm_to_node(),
> >>> which assumes that all localities have been parsed with SRAT previously.
> >>> SRAT does not list I/O localities, where as SLIT lists all localities
> >>
> >>> including I/Os.  Hence, pxm_to_node() returns NUMA_NO_NODE (-1) for
> >>> an I/O locality.  I/O localities are not supported and are ignored
> >>> today, but emitting such warning message leads unnecessary confusion.
> >>
> >> In this case, the warning message should not be shown. But if SLIT table
> >> is really broken, the message should be shown. Your patch seems to not care
> >> for second case.
> >
> > In the second case, I assume you are worrying about the case of SLIT
> > table with bad locality numbers.  Since SLIT is a matrix of the number
> > of localities, it is only possible by making the table bigger than
> > necessary.  Such excessive localities are safe to ignore (as they are
> > ignored today) and regular users have nothing to concern about them.
> > The warning message in this case may be helpful for platform vendors to
> > test their firmware, but they have plenty of other methods to verify
> > their SLIT table.
> 
> I understood it. So,
> 
> Reviewed-by : Yasuaki Ishimatsu

Great.  Thanks Yasuaki!
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

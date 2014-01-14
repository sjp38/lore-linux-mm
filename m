Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f182.google.com (mail-gg0-f182.google.com [209.85.161.182])
	by kanga.kvack.org (Postfix) with ESMTP id 84C906B0031
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 20:30:15 -0500 (EST)
Received: by mail-gg0-f182.google.com with SMTP id e27so1974153gga.13
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 17:30:15 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id v3si22817436yhv.169.2014.01.13.17.30.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jan 2014 17:30:14 -0800 (PST)
Message-ID: <52D49307.3040406@zytor.com>
Date: Mon, 13 Jan 2014 17:29:43 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] x86, e820 disable ACPI Memory Hotplug if memory mapping
 is specified by user [v2]
References: <1389380698-19361-1-git-send-email-prarit@redhat.com>		 <1389380698-19361-4-git-send-email-prarit@redhat.com>		 <alpine.DEB.2.02.1401111624170.20677@be1.lrz>	 <52D32962.5050908@redhat.com>		 <CAHGf_=qWB81f8fdDdjaXXh1JoSDUsJmcEHwH+CEJ2E-5XWz6qA@mail.gmail.com>		 <52D4793E.8070102@redhat.com> <1389659632.1792.247.camel@misato.fc.hp.com>	 <52D48A9D.7000003@zytor.com> <1389661746.1792.254.camel@misato.fc.hp.com>
In-Reply-To: <1389661746.1792.254.camel@misato.fc.hp.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: Prarit Bhargava <prarit@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Bodo Eggert <7eggert@gmx.de>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, the arch/x86 maintainers <x86@kernel.org>, Len Brown <lenb@kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Linn Crosetto <linn@hp.com>, Pekka Enberg <penberg@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tang Chen <tangchen@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Vivek Goyal <vgoyal@redhat.com>, dyoung@redhat.com, linux-acpi@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 01/13/2014 05:09 PM, Toshi Kani wrote:
> 
> In majority of the cases, memmap=exactmap is used for kdump and the
> firmware info is sane.  So, I think we should keep NUMA enabled since it
> could be useful when multiple CPUs are enabled for kdump.
> 

Rather unlikely since all of the kdump memory is likely to sit in a
single node.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

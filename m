Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f51.google.com (mail-lf0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id DEECC6B0005
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 21:10:23 -0500 (EST)
Received: by mail-lf0-f51.google.com with SMTP id l143so23155330lfe.2
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 18:10:23 -0800 (PST)
Received: from v094114.home.net.pl (v094114.home.net.pl. [79.96.170.134])
        by mx.google.com with SMTP id n197si2470663lfa.200.2016.02.17.18.10.22
        for <linux-mm@kvack.org>;
        Wed, 17 Feb 2016 18:10:22 -0800 (PST)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH v5 RESEND 0/5] Make cpuid <-> nodeid mapping persistent
Date: Thu, 18 Feb 2016 03:11:46 +0100
Message-ID: <1672109.ebeP8evnQp@vostro.rjw.lan>
In-Reply-To: <56C525F9.1040107@cn.fujitsu.com>
References: <1453702100-2597-1-git-send-email-tangchen@cn.fujitsu.com> <CAJZ5v0go7tZiDkh2novJKiDmYv_ge7Y-rQLC5ohRC=qSDJ+5-Q@mail.gmail.com> <56C525F9.1040107@cn.fujitsu.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>, chen.tang@easystack.cn, cl@linux.com, Tejun Heo <tj@kernel.org>, Jiang Liu <jiang.liu@linux.intel.com>, mika.j.penttila@gmail.com, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, Len Brown <len.brown@intel.com>, x86@kernel.org, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thursday, February 18, 2016 10:01:29 AM Zhu Guihua wrote:
> Hi Rafael,
> 
> On 02/03/2016 08:02 PM, Rafael J. Wysocki wrote:
> > Hi,
> >
> > On Wed, Feb 3, 2016 at 10:14 AM, Zhu Guihua <zhugh.fnst@cn.fujitsu.com> wrote:
> >> On 01/25/2016 02:12 PM, Tang Chen wrote:
> >>> Hi Rafael, Len,
> >>>
> >>> Would you please help to review the ACPI part of this patch-set ?
> >>
> >> Can anyone help to review this?
> > I'm planning to look into this more thoroughly in the next few days.
> 
> Were you reviewing this ?

Yes.

They generally look OK to me, but then I'd like the x86 maintainers to have
a look at them too.

There still are a few things I need to verify, but should be able to do that
by the end of this week.

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

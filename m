Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id D4E6F6B0035
	for <linux-mm@kvack.org>; Fri, 25 Jul 2014 12:27:34 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id ho1so1285820wib.14
        for <linux-mm@kvack.org>; Fri, 25 Jul 2014 09:27:32 -0700 (PDT)
Received: from service88.mimecast.com (service88.mimecast.com. [195.130.217.12])
        by mx.google.com with ESMTP id pg3si18866411wjb.99.2014.07.25.09.27.30
        for <linux-mm@kvack.org>;
        Fri, 25 Jul 2014 09:27:31 -0700 (PDT)
From: Wilco Dijkstra <Wilco.Dijkstra@arm.com>
Date: Fri, 25 Jul 2014 17:27:26 +0100
Subject: RE: Background page clearing
Message-ID: <A610E03AD50BFC4D95529A36D37FA55E3756EFEC80@GEORGE.Emea.Arm.com>
References: <000001cfa81a$110d15c0$33274140$@com>
 <53D27590.2090500@intel.com>
In-Reply-To: <53D27590.2090500@intel.com>
Content-Language: en-US
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> On 07/25/2014 08:06 AM, Wilco Dijkstra wrote:
> > Is there a reason Linux does not do background page clearing like other=
 OSes to reduce this
> > overhead? It would be a good fit for typical mobile workloads (bursts o=
f high activity
> followed by
> > periods of low activity).
>
> If the page is being allocated, it is about to be used and be brought in
> to the CPU's cache.  If we zero it close to this use, we only pay to
> bring it in to the CPU's cache once.  Or so goes the theory...

I can see the reasoning for 4KB pages and small allocations (eg. stack),
but would that ever be true for huge pages?

> I tried a zero-on-free implementation a year or so ago.  It helped some
> workloads and hurt others.  The gains were not large enough or
> widespread enough to merit pushing it in to the kernel.

Was that literally zero-on-free or zero in the background? Was the result
the same for different page sizes? My guess is that the result will be
different for huge pages.

Wilco

-- IMPORTANT NOTICE: The contents of this email and any attachments are con=
fidential and may also be privileged. If you are not the intended recipient=
, please notify the sender immediately and do not disclose the contents to =
any other person, use it for any purpose, or store or copy the information =
in any medium.  Thank you.

ARM Limited, Registered office 110 Fulbourn Road, Cambridge CB1 9NJ, Regist=
ered in England & Wales, Company No:  2557590
ARM Holdings plc, Registered office 110 Fulbourn Road, Cambridge CB1 9NJ, R=
egistered in England & Wales, Company No:  2548782

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

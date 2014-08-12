Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 4CEB36B0035
	for <linux-mm@kvack.org>; Tue, 12 Aug 2014 12:20:56 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id f8so6061269wiw.0
        for <linux-mm@kvack.org>; Tue, 12 Aug 2014 09:20:55 -0700 (PDT)
Received: from mtaout22.012.net.il (mtaout22.012.net.il. [80.179.55.172])
        by mx.google.com with ESMTP id wr4si31458764wjb.15.2014.08.12.09.20.54
        for <linux-mm@kvack.org>;
        Tue, 12 Aug 2014 09:20:54 -0700 (PDT)
Received: from conversion-daemon.a-mtaout22.012.net.il by a-mtaout22.012.net.il (HyperSendmail v2007.08) id <0NA700I00BZFQI00@a-mtaout22.012.net.il> for linux-mm@kvack.org; Tue, 12 Aug 2014 19:20:53 +0300 (IDT)
Date: Tue, 12 Aug 2014 19:20:52 +0300
From: Oren Twaig <oren@scalemp.com>
Subject: Re: x86: vmalloc and THP
In-reply-to: <20140812060745.GA7987@node.dhcp.inet.fi>
Message-id: <53EA3EE4.6090100@scalemp.com>
MIME-version: 1.0
Content-type: text/plain; charset=ISO-8859-1; format=flowed
Content-transfer-encoding: 7bit
References: <53E99F86.5020100@scalemp.com> <20140812060745.GA7987@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "Shai Fultheim (Shai@ScaleMP.com)" <Shai@scalemp.com>

Hi Kirill,

I saw the thread has developed nicely :), still - wanted to answer your 
question
below.

On 8/12/2014 9:07 AM, Kirill A. Shutemov wrote:
> On Tue, Aug 12, 2014 at 08:00:54AM +0300, Oren Twaig wrote:
>> <html style="direction: ltr;">
> plain/text, please.
Yes - noticed the html, sent again in plain text.
>> If not, is there any fast way to change this behavior ? Maybe by
>> changing the granularity/alignment of such allocations to allow such
>> mapping ?
> What's the point to use vmalloc() in this case?
I've noticed that some lock/s are using linear addresses which are
located at 0xffffc901922b4500 and from what I understand
from mm.txt (kernel 3.0.101):
*ffffc90000000000 - ffffe8ffffffffff (=45 bits) vmalloc/ioremap space

*So I'm not sure who/how/why this lock got allocated there, but obviously
it is using that linear set. No ?

>


---
This email is free from viruses and malware because avast! Antivirus protection is active.
http://www.avast.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

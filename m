Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 064326B0498
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 18:44:13 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id 61so20080plz.1
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 15:44:12 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p23sor461373pgd.286.2018.01.03.15.44.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jan 2018 15:44:11 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: "bad pmd" errors + oops with KPTI on 4.14.11 after loading X.509 certs
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <alpine.DEB.2.20.1801032358200.1957@nanos>
Date: Wed, 3 Jan 2018 15:44:09 -0800
Content-Transfer-Encoding: 7bit
Message-Id: <0694E863-477E-45D1-AFE0-DE26933553FB@amacapital.net>
References: <CAD3VwcrHs8W_kMXKyDjKnjNDkkK57-0qFS5ATJYCphJHU0V3ow@mail.gmail.com> <20180103084600.GA31648@trogon.sfo.coreos.systems> <20180103092016.GA23772@kroah.com> <20180103154833.fhkbwonz6zhm26ax@gmail.com> <20180103223222.GA22901@trogon.sfo.coreos.systems> <alpine.DEB.2.20.1801032334180.1957@nanos> <20180103224902.GB22901@trogon.sfo.coreos.systems> <alpine.DEB.2.20.1801032355330.1957@nanos> <alpine.DEB.2.20.1801032358200.1957@nanos>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Benjamin Gilbert <benjamin.gilbert@coreos.com>, Ingo Molnar <mingo@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, x86@kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, stable@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>



> On Jan 3, 2018, at 2:58 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> 
> 
> 
>> On Wed, 3 Jan 2018, Thomas Gleixner wrote:
>> 
>>> On Wed, 3 Jan 2018, Benjamin Gilbert wrote:
>>>> On Wed, Jan 03, 2018 at 11:34:46PM +0100, Thomas Gleixner wrote:
>>>> Can you please send me your .config and a full dmesg ?
>>> 
>>> I've attached a serial log from a local QEMU.  I can rerun with a higher
>>> loglevel if need be.
>> 
>> Thanks!
>> 
>> Cc'ing Andy who might have an idea and he's probably more away than I
> 
> s/away/awake/ just to demonstrate the state I'm in ...
> 
>> am. Will have a look tomorrow if Andy does not beat me to it.

Can you forward me more of the thread?

>> 
>> Thanks,
>> 
>>    tglx
>> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

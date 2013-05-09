Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 8CA156B0038
	for <linux-mm@kvack.org>; Thu,  9 May 2013 09:17:48 -0400 (EDT)
Received: by mail-ob0-f172.google.com with SMTP id fb19so1702372obc.17
        for <linux-mm@kvack.org>; Thu, 09 May 2013 06:17:47 -0700 (PDT)
Message-ID: <518BA1F6.4030908@gmail.com>
Date: Thu, 09 May 2013 21:17:42 +0800
From: Will Huck <will.huckk@gmail.com>
MIME-Version: 1.0
Subject: Re: OOM-killer and strange RSS value in 3.9-rc7
References: <alpine.DEB.2.02.1304161315290.30779@chino.kir.corp.google.com> <20130417094750.GB2672@localhost.localdomain> <20130417141909.GA24912@dhcp22.suse.cz> <20130418101541.GC2672@localhost.localdomain> <20130418175513.GA12581@dhcp22.suse.cz> <20130423131558.GH8001@dhcp22.suse.cz> <20130424044848.GI2672@localhost.localdomain> <20130424094732.GB31960@dhcp22.suse.cz> <0000013e3cb0340d-00f360e3-076b-478e-b94c-ddd4476196ce-000000@email.amazonses.com> <20130425060705.GK2672@localhost.localdomain> <0000013e42332267-0b7fb3c0-9150-4058-8850-ae094b455b15-000000@email.amazonses.com> <517B8A5D.1030308@gmail.com> <0000013e56450fd2-c7a854d1-ff7f-47a7-a235-30721fead5e0-000000@email.amazonses.com> <5180883F.3040003@gmail.com> <0000013e65cbcdc9-9a394918-ea30-4d91-97f9-77af82fcda3b-000000@email.amazonses.com>
In-Reply-To: <0000013e65cbcdc9-9a394918-ea30-4d91-97f9-77af82fcda3b-000000@email.amazonses.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org

On 05/02/2013 11:10 PM, Christoph Lameter wrote:
> On Wed, 1 May 2013, Will Huck wrote:
>
>>> Age refers to the mininum / avg / maximum age of the object in ticks.
>> Why need monitor the age of the object?
>
> Will give you some idea as to when these objects were created.

Thanks for your clarify. ;-) But why mininum / avg / maximum instead of 
a single value?

>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

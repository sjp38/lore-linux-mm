Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id D266B6B0031
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 00:49:39 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so2213713pab.35
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 21:49:39 -0800 (PST)
Received: from psmtp.com ([74.125.245.188])
        by mx.google.com with SMTP id mj9si7422820pab.190.2013.11.19.21.49.37
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 21:49:38 -0800 (PST)
Received: by mail-oa0-f41.google.com with SMTP id g12so10167112oah.28
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 21:49:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <87y54kvz87.fsf@tassilo.jf.intel.com>
References: <1384822222-28795-1-git-send-email-andi@firstfloor.org>
 <20131119104203.GB18872@dhcp22.suse.cz> <20131119184200.GD29695@two.firstfloor.org>
 <20131119191135.GA8634@dhcp22.suse.cz> <20131119201333.GD19762@tassilo.jf.intel.com>
 <20131119212123.GA9339@dhcp22.suse.cz> <87y54kvz87.fsf@tassilo.jf.intel.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Wed, 20 Nov 2013 00:49:16 -0500
Message-ID: <CAHGf_=py9fq51viTx1RfmAMf=t=TX=86nb8h6F7nW7qw=pCRow@mail.gmail.com>
Subject: Re: [PATCH] Expose sysctls for enabling slab/file_cache interleaving
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Nov 19, 2013 at 4:49 PM, Andi Kleen <andi@firstfloor.org> wrote:
> Michal Hocko <mhocko@suse.cz> writes:
>>
>> Another option would be to use sysctl values for the top cpuset as a
>> default. But then why not just do it manually without sysctl?
>
> I want to provide an alternative to having to use cpusets to use this,
> that is actually usable for normal people.
>
> Also this is really a global setting in my mind.
>
>> If you create a cpuset and explicitly disable spreading then you would
>> be quite surprised that your process gets pages from all nodes, no?
>
> If I enable it globally using a sysctl I would be quite surprised
> if some cpuset can override it.
>
> That argument is equally valid :-)
>
> The user configured an inconsistent configuration, and the kernel
> has to make a decision somehow.
>
> In the end it is arbitary, but not having to check the cpuset
> here is a lot cheaper, so I prefer the "sysctl has priority"
> option.

sorry.
I agree with Michael. If there are large scope knob and small scope knob,
the small scope should have high priority. It is one of best practice of the
interface design.

However, I fully agree the basic concept of this patch. sysctl help a
lot of admins.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

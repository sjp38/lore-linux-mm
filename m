Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 102216B0101
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 11:02:50 -0400 (EDT)
Received: by mail-qa0-f44.google.com with SMTP id o13so336076qaj.10
        for <linux-mm@kvack.org>; Fri, 05 Apr 2013 08:02:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <515CF884.8010103@gmail.com>
References: <20130325134247.GB1393@localhost.localdomain> <515CF884.8010103@gmail.com>
From: Andrew Shewmaker <agshew@gmail.com>
Date: Fri, 5 Apr 2013 09:02:29 -0600
Message-ID: <CAF-E8XFQFm9GrBnkax+TiByUPHxp=Ukp1LcuAWjYL0OeLE1Saw@mail.gmail.com>
Subject: Re: [PATCH v7 2/2] mm: replace hardcoded 3% with admin_reserve_pages knob
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, alan@lxorguk.ukuu.org.uk, ric.masonn@gmail.com

On Wed, Apr 3, 2013 at 9:50 PM, Simon Jeons <simon.jeons@gmail.com> wrote:
>> FAQ
>>
...
>>   * How do you calculate a minimum useful reserve?
>>
>>     A user or the admin needs enough memory to login and perform
>>     recovery operations, which includes, at a minimum:
>>
>>     sshd or login + bash (or some other shell) + top (or ps, kill, etc.)
>>
>>     For overcommit 'guess', we can sum resident set sizes (RSS).
>>     On x86_64 this is about 8MB.
>>
>>     For overcommit 'never', we can take the max of their virtual sizes
>> (VSZ)
>>     and add the sum of their RSS.
>>     On x86_64 this is about 128MB.
>
>
> 1.Why has this different between guess and never?

The default, overcommit 'guess' mode, only needs a reserve for
what the recovery programs will typically use. Overcommit 'never'
mode will only successfully launch an app when it can fulfill all of
its requested memory allocations--even if the app only uses a
fraction of what it asks for.

> 2.You just test x86/x86_64, other platforms also will use memory overcommit,
> did you test them?

No, I haven't. Unfortunately, I don't currently have any other platforms to test
with. I'll see what I can do.

Thanks,

Andrew

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

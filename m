Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id C4A6090002E
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 08:34:53 -0400 (EDT)
Received: by obcuy5 with SMTP id uy5so8397941obc.11
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 05:34:53 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id m17si2036671oik.33.2015.03.11.05.34.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 11 Mar 2015 05:34:53 -0700 (PDT)
Message-ID: <55003666.3020100@oracle.com>
Date: Wed, 11 Mar 2015 08:34:46 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: kill kmemcheck
References: <1426074547-21888-1-git-send-email-sasha.levin@oracle.com> <20150311081909.552e2052@grimm.local.home>
In-Reply-To: <20150311081909.552e2052@grimm.local.home>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, netdev@vger.kernel.org, linux-arch@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org

On 03/11/2015 08:19 AM, Steven Rostedt wrote:
> I removed the Cc list as it was so large, I'm sure that it exceeded the
> LKML Cc size limit, and your email probably didn't make it to the list
> (or any of them).

Thanks. I'll resend in a bit if it doesn't show up on lkml.org.

> On Wed, 11 Mar 2015 07:43:59 -0400
> Sasha Levin <sasha.levin@oracle.com> wrote:
> 
>> > As discussed on LSF/MM, kill kmemcheck.
>> > 
>> > KASan is a replacement that is able to work without the limitation of
>> > kmemcheck (single CPU, slow). KASan is already upstream.
>> > 
>> > We are also not aware of any users of kmemcheck (or users who don't consider
>> > KASan as a suitable replacement).
> I use kmemcheck and I am unaware of KASan. I'll try to play with KASan
> and see if it suites my needs.

Fair enough. We knew there are existing kmemcheck users, but KASan should be
superior both in performance and the scope of bugs it finds. It also shouldn't
impose new limitations beyond requiring gcc 4.9.2+.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

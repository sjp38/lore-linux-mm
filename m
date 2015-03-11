Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id B656490002E
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 09:39:40 -0400 (EDT)
Received: by obcva2 with SMTP id va2so8756903obc.13
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 06:39:40 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id f20si2077470oig.106.2015.03.11.06.39.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 11 Mar 2015 06:39:40 -0700 (PDT)
Message-ID: <55004595.7020304@oracle.com>
Date: Wed, 11 Mar 2015 09:39:33 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: kill kmemcheck
References: <1426074547-21888-1-git-send-email-sasha.levin@oracle.com>	<20150311081909.552e2052@grimm.local.home>	<55003666.3020100@oracle.com> <20150311084034.04ce6801@grimm.local.home>
In-Reply-To: <20150311084034.04ce6801@grimm.local.home>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, netdev@vger.kernel.org, linux-arch@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org

On 03/11/2015 08:40 AM, Steven Rostedt wrote:
> On Wed, 11 Mar 2015 08:34:46 -0400
> Sasha Levin <sasha.levin@oracle.com> wrote:
> 
>> > Fair enough. We knew there are existing kmemcheck users, but KASan should be
>> > superior both in performance and the scope of bugs it finds. It also shouldn't
>> > impose new limitations beyond requiring gcc 4.9.2+.
>> >
> Ouch! OK, then I can't use it. I'm currently compiling with gcc 4.6.3.
> 
> It will be a while before I upgrade my build farm to something newer.

Are you actually compiling new kernels with 4.6.3, or are you using older
kernels as well?

There's no real hurry to kill kmemcheck right now, but we do want to stop
supporting that in favour of KASan.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

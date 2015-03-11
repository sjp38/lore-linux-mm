Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 3ACBB900049
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 10:36:02 -0400 (EDT)
Received: by wiwh11 with SMTP id h11so12253681wiw.5
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 07:36:01 -0700 (PDT)
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id vt8si5726260wjc.208.2015.03.11.07.36.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Mar 2015 07:36:00 -0700 (PDT)
Received: by wghl2 with SMTP id l2so9687787wgh.8
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 07:36:00 -0700 (PDT)
Message-ID: <550052CD.5040303@plexistor.com>
Date: Wed, 11 Mar 2015 16:35:57 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: kill kmemcheck
References: <1426074547-21888-1-git-send-email-sasha.levin@oracle.com>	<20150311081909.552e2052@grimm.local.home>	<55003666.3020100@oracle.com> <20150311084034.04ce6801@grimm.local.home> <55004595.7020304@oracle.com>
In-Reply-To: <55004595.7020304@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, Steven Rostedt <rostedt@goodmis.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, netdev@vger.kernel.org, linux-arch@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org

On 03/11/2015 03:39 PM, Sasha Levin wrote:
> On 03/11/2015 08:40 AM, Steven Rostedt wrote:
>> On Wed, 11 Mar 2015 08:34:46 -0400
>> Sasha Levin <sasha.levin@oracle.com> wrote:
>>
>>>> Fair enough. We knew there are existing kmemcheck users, but KASan should be
>>>> superior both in performance and the scope of bugs it finds. It also shouldn't
>>>> impose new limitations beyond requiring gcc 4.9.2+.
>>>>
>> Ouch! OK, then I can't use it. I'm currently compiling with gcc 4.6.3.
>>
>> It will be a while before I upgrade my build farm to something newer.
> 
> Are you actually compiling new kernels with 4.6.3, or are you using older
> kernels as well?
> 
> There's no real hurry to kill kmemcheck right now, but we do want to stop
> supporting that in favour of KASan.
> 

Just my $0.017 for me I wish there was the single config MEM_CHECK and
the new or old would be selected automatically depending on enabling
factors, for example gcc version, if arch dependent and so on.

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

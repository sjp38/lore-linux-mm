Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id C72F46B0007
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 09:23:52 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id g17-v6so12887030wrw.6
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 06:23:52 -0800 (PST)
Received: from vulcan.natalenko.name (vulcan.natalenko.name. [104.207.131.136])
        by mx.google.com with ESMTPS id c10-v6si17078373wrt.340.2018.11.13.06.23.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 13 Nov 2018 06:23:51 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Tue, 13 Nov 2018 15:23:50 +0100
From: Oleksandr Natalenko <oleksandr@natalenko.name>
Subject: Re: [PATCH V3] KSM: allow dedup all tasks memory
In-Reply-To: 
 <<CAG48ez0ZprqUYGZFxcrY6U3Dnwt77q1NJXzzpsn1XNkRuXVppw@mail.gmail.com>>
Message-ID: <d43da6ad1a3c164aa03e0f22f065591a@natalenko.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jannh@google.com
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, timofey.titovets@synesis.ru, willy@infradead.org

Hi.

> Yep. However, so far, it requires an application to explicitly opt in
> to this behavior, so it's not all that bad. Your patch would remove
> the requirement for application opt-in, which, in my opinion, makes
> this way worse and reduces the number of applications for which this
> is acceptable.

The default is to maintain the old behaviour, so unless the explicit 
decision is made by the administrator, no extra risk is imposed.

> As far as I know, basically nobody is using KSM at this point. There
> are blog posts from several cloud providers about these security risks
> that explicitly state that they're not using memory deduplication.

I tend to disagree here. Based on both what my company does and what 
UKSM users do, memory dedup is a desired option (note "option" word 
here, not the default choice).

Thanks.

-- 
   Oleksandr Natalenko (post-factum)

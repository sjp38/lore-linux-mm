Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id 736026B0035
	for <linux-mm@kvack.org>; Mon,  1 Sep 2014 08:47:21 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id t60so5412879wes.32
        for <linux-mm@kvack.org>; Mon, 01 Sep 2014 05:47:20 -0700 (PDT)
Received: from ducie-dc1.codethink.co.uk (ducie-dc1.codethink.co.uk. [185.25.241.215])
        by mx.google.com with ESMTPS id l3si1040494wjy.97.2014.09.01.05.47.19
        for <linux-mm@kvack.org>
        (version=TLSv1.1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 01 Sep 2014 05:47:20 -0700 (PDT)
Message-ID: <54046ACE.2080701@codethink.co.uk>
Date: Mon, 01 Sep 2014 13:47:10 +0100
From: Rob Jones <rob.jones@codethink.co.uk>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] Tidy up of modules using seq_open()
References: <1409328400-18212-1-git-send-email-rob.jones@codethink.co.uk> <20140829121426.4044f2a330f9d74fe37f7825@linux-foundation.org>
In-Reply-To: <20140829121426.4044f2a330f9d74fe37f7825@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jbaron@akamai.com, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, linux-kernel@codethink.co.uk

On 29/08/14 20:14, Andrew Morton wrote:
> On Fri, 29 Aug 2014 17:06:36 +0100 Rob Jones <rob.jones@codethink.co.uk> wrote:
>
>> Many modules use seq_open() when seq_open_private() or
>> __seq_open_private() would be more appropriate and result in
>> simpler, cleaner code.
>>
>> This patch sequence changes those instances in IPC, MM and LIB.
>
> Looks good to me.
>
> I can't begin to imagine why we added the global, exported-to-modules
> seq_open_private() without bothering to document it, so any time you
> feel like adding the missing kerneldoc...

Already done, I waited for that to be accepted before I submitted this
patch :-)

>
> And psize should have been size_t, ho hum.

I'll fix that while I'm in the vicinity.

>
>

-- 
Rob Jones
Codethink Ltd
mailto:rob.jones@codethink.co.uk
tel:+44 161 236 5575

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

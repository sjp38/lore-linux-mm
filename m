Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C000C04AAF
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 13:57:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0748D20657
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 13:57:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0748D20657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9553D6B0008; Thu, 16 May 2019 09:57:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 903FD6B000A; Thu, 16 May 2019 09:57:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 77E176B000C; Thu, 16 May 2019 09:57:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0F9B56B0008
	for <linux-mm@kvack.org>; Thu, 16 May 2019 09:57:03 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id l10so513073ljj.18
        for <linux-mm@kvack.org>; Thu, 16 May 2019 06:57:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=hMg6dnhzdcWw2ldpfI8t/8HN5Ji8Fr/MgcAD4iNFIxU=;
        b=oxU8nHkhMsIl2UClofRxH6ACQ94WtzNJ9iy/azDXlg3yh4pkJKvxLIzZvHjx/OIs1D
         DcU7We938EIB+2tS96PTAx3vHflu3nffakN2vU0KAfIC+RexK9lMfI9jhDEwTQEyeX0X
         GmmsUpAtJwLErC5GIES3bJzRZ5QKrcdwc34Nc2VfdNuJDGPEGqG9fdJZh52WD3UxqOQJ
         pzaoa3dh/xKiMX9yGGdGk1nDcGdr8bEiAkkRlnldTJjHviF6hOcQn+CsgAH5FBoJ9eTg
         MRbb2I5GE/WkK4vTaWKDV03gqHySAwubTq5yz/2TW8sc2E/9awRbamR6dlbyIk7Ryma1
         nYcg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAVGr4zSJ0SJgegne7ip1ziXlYqHMQ+kY7oPza69YavQWR17orr4
	4l8nWWaxqCq7t9nshu88h0ker9QsqBY8TSB/JX5LD3/Mnl/cPn8vsLJT/bBtffEpCcIhDMbmX9t
	GL+GM1CwhoC8du3M3tIk7o08MYCzEYchmodvc+I5f289FADNcp4MTOJoSJX8pKGCcNg==
X-Received: by 2002:a2e:4555:: with SMTP id s82mr24299651lja.15.1558015022338;
        Thu, 16 May 2019 06:57:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyQObrTx4ExkV55gLOZrICgS+Kze8/G0K6US0Kc1N7bWUGoLC7t3jtdS+U7mY7FTZ1TB8NO
X-Received: by 2002:a2e:4555:: with SMTP id s82mr24299615lja.15.1558015021605;
        Thu, 16 May 2019 06:57:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558015021; cv=none;
        d=google.com; s=arc-20160816;
        b=Wqv2xPqzsgKGU/RK7+9ltiFHCbgQU/+lhTD5uJTB7ioCJ5PUTQ/WxAfQtCKWpheaqC
         X1XVDll+iBvf1QxgJ/3pzK76KCcV67nQFND6W/hRsnRqngV9QZ0VpXDfXE5b9ndVlrXY
         UXEt6J9R7Z6Wap/jHUZ29gElSNNaMTKDRXw3WcuIjIqdAH812PHwSlx31kxPn3mPdpLA
         hA/DqanQHLUEyOjqSPvyIQ5n+pRs0laW/E5y5W+a1DjTjHQ3UEEUEazHJYuXfc13nqzf
         ZkUZEihFRfsmsNdhjP2RB6jDOkMwFkX6xTCOEAjMQIFm/2HgEhjoL/c4tMXlqkJ1vE6G
         37zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=hMg6dnhzdcWw2ldpfI8t/8HN5Ji8Fr/MgcAD4iNFIxU=;
        b=f6cydcrqLDXri+BBuIprJCw8FJsF36MX67UpvRvyYXg7yiegKB8RXMozqCqLoqSFtq
         ersONDepXa7+b5m60uiw0nenwlG1yuU4/8N5voG7WrQuGgEVXDYsK+BYqidbqa0HYwLu
         fWH+/jWAPNyi3dGSbOu4tFa3uqE3OTdoo+j726qfsxc0+Aupt64Hu7TvY0Tp1pcZYmzx
         KhgyCeQRp/z9He203OlLuPDkZuMzra0J5fVTSb4psysF7JJGtlaONluV6HZWn0839qZB
         oxVOEFra89YfbtJIWHtzSQTFmvS8UMCCBnlu46212cIC+4qLp3m+AeO0bb1T93b6M7V0
         WU6g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id a8si5082117lfh.144.2019.05.16.06.57.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 May 2019 06:57:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hRGsK-00075H-1m; Thu, 16 May 2019 16:56:48 +0300
Subject: Re: [PATCH RFC 0/5] mm: process_vm_mmap() -- syscall for duplication
 a process mapping
To: Jann Horn <jannh@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>,
 keith.busch@intel.com, "Kirill A . Shutemov"
 <kirill.shutemov@linux.intel.com>, pasha.tatashin@oracle.com,
 Alexander Duyck <alexander.h.duyck@linux.intel.com>, ira.weiny@intel.com,
 Andrey Konovalov <andreyknvl@google.com>, arunks@codeaurora.org,
 Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>,
 Rik van Riel <riel@surriel.com>, Kees Cook <keescook@chromium.org>,
 hannes@cmpxchg.org, npiggin@gmail.com,
 Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
 Shakeel Butt <shakeelb@google.com>, Roman Gushchin <guro@fb.com>,
 Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>,
 Jerome Glisse <jglisse@redhat.com>, Mel Gorman
 <mgorman@techsingularity.net>, daniel.m.jordan@oracle.com,
 kernel list <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
 Linux API <linux-api@vger.kernel.org>
References: <155793276388.13922.18064660723547377633.stgit@localhost.localdomain>
 <CAG48ez3EOwLd8A6Ku53vKLdofmZAh1ZYfkK4rVgSgM8ZfcR4zg@mail.gmail.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <89124a45-ddfd-9c96-1957-304f67d4b9bc@virtuozzo.com>
Date: Thu, 16 May 2019 16:56:46 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CAG48ez3EOwLd8A6Ku53vKLdofmZAh1ZYfkK4rVgSgM8ZfcR4zg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 16.05.2019 16:32, Jann Horn wrote:
> On Wed, May 15, 2019 at 5:11 PM Kirill Tkhai <ktkhai@virtuozzo.com> wrote:
>> This patchset adds a new syscall, which makes possible
>> to clone a mapping from a process to another process.
>> The syscall supplements the functionality provided
>> by process_vm_writev() and process_vm_readv() syscalls,
>> and it may be useful in many situation.
> [...]
>> The proposed syscall aims to introduce an interface, which
>> supplements currently existing process_vm_writev() and
>> process_vm_readv(), and allows to solve the problem with
>> anonymous memory transfer. The above example may be rewritten as:
>>
>>         void *buf;
>>
>>         buf = mmap(NULL, n * PAGE_SIZE, PROT_READ|PROT_WRITE,
>>                    MAP_PRIVATE|MAP_ANONYMOUS, ...);
>>         recv(sock, buf, n * PAGE_SIZE, 0);
>>
>>         /* Sign of @pid is direction: "from @pid task to current" or vice versa. */
>>         process_vm_mmap(-pid, buf, n * PAGE_SIZE, remote_addr, PVMMAP_FIXED);
>>         munmap(buf, n * PAGE_SIZE);
> 
> In this specific example, an alternative would be to splice() from the
> socket into /proc/$pid/mem, or something like that, right?
> proc_mem_operations has no ->splice_read() at the moment, and it'd
> need that to be more efficient, but that could be built without
> creating new UAPI, right?

I have just never seen, a socket memory may be preempted into swap.
If so, there is a fundamental problem.
But, anyway, like you guessed below:
 
> But I guess maybe your workload is not that simple? What do you
> actually do with the received data between receiving it and shoving it
> over into the other process?

Data are usually sent encrypted and compressed by socket, so there is no
possibility to go this way. You may want to do everything with data,
before passing to another process.

Kirill


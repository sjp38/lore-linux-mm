Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 949FB6B002C
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 10:52:11 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id l126so117042756wml.1
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 07:52:11 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t190si44167237wme.110.2015.12.22.07.52.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 22 Dec 2015 07:52:10 -0800 (PST)
Subject: Re: [PATCH V2] Documentation: Describe the shared memory
 usage/accounting
References: <1281769343.11551980.1447959500824.JavaMail.zimbra@redhat.com>
 <5678187A.5070307@suse.cz>
 <1612313460.962272.1450721278983.JavaMail.zimbra@redhat.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <567971A9.3010506@suse.cz>
Date: Tue, 22 Dec 2015 16:52:09 +0100
MIME-Version: 1.0
In-Reply-To: <1612313460.962272.1450721278983.JavaMail.zimbra@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rodrigo Freire <rfreire@redhat.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com

On 12/21/2015 07:07 PM, Rodrigo Freire wrote:
>
> The Shared Memory accounting support is present in Kernel since
> commit 4b02108ac1b3 ("mm: oom analysis: add shmem vmstat") and in
> userland free(1) since 2014. This patch updates the Documentation to
> reflect this change.
>
> Signed-off-by: Rodrigo Freire <rfreire@redhat.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

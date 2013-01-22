Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id B3E166B0004
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 21:34:08 -0500 (EST)
Message-ID: <50FDFA9B.5060002@redhat.com>
Date: Mon, 21 Jan 2013 21:34:03 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 1/3 v2]mm: don't inline page_mapping()
References: <20130122022919.GA12293@kernel.org>
In-Reply-To: <20130122022919.GA12293@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, minchan@kernel.org

On 01/21/2013 09:29 PM, Shaohua Li wrote:
>
> According to akpm, this saves 1/2k text and makes things simple of next patch.
>
> Suggested-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Shaohua Li <shli@fusionio.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

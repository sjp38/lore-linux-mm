Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 417BC6B00D3
	for <linux-mm@kvack.org>; Sun, 26 May 2013 12:32:21 -0400 (EDT)
Received: by mail-ve0-f176.google.com with SMTP id jz10so4485226veb.7
        for <linux-mm@kvack.org>; Sun, 26 May 2013 09:32:20 -0700 (PDT)
Message-ID: <51A23911.3060802@gmail.com>
Date: Sun, 26 May 2013 12:32:17 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/02] swapon: allow a more flexible swap discard policy
References: <cover.1369529143.git.aquini@redhat.com> <6346c223ca2acb30b35480b9d51638466aac5fe6.1369530033.git.aquini@redhat.com>
In-Reply-To: <6346c223ca2acb30b35480b9d51638466aac5fe6.1369530033.git.aquini@redhat.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, shli@kernel.org, kzak@redhat.com, jmoyer@redhat.com, kosaki.motohiro@gmail.com, riel@redhat.com, lwoodman@redhat.com, mgorman@suse.de

(5/26/13 12:31 AM), Rafael Aquini wrote:
> Introduce the necessary changes to swapon(8) allowing a sysadmin to leverage
> the new changes introduced to sys_swapon by "swap: discard while swapping
> only if SWAP_FLAG_DISCARD_PAGES", therefore allowing a more flexible set of
> choices when selection the discard policy for mounted swap areas.
> This patch introduces the following optional arguments to the already
> existent swapon(8) "--discard" option, in order to allow a discard type to 
> be selected at swapon time:
>  * once    : only single-time area discards are issued. (swapon)
>  * pages   : discard freed pages before they are reused.
> If no policy is selected both discard types are enabled. (default)
> 
> Signed-off-by: Rafael Aquini <aquini@redhat.com>

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

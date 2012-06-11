Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 6EFFD6B009B
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 01:21:01 -0400 (EDT)
Message-ID: <4FD5803A.3000201@kernel.org>
Date: Mon, 11 Jun 2012 14:20:58 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH v3 01/10] mm: frontswap: remove casting from function
 calls through ops structure
References: <1339325468-30614-1-git-send-email-levinsasha928@gmail.com> <1339325468-30614-2-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1339325468-30614-2-git-send-email-levinsasha928@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: dan.magenheimer@oracle.com, konrad.wilk@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/10/2012 07:50 PM, Sasha Levin wrote:

> Removes unneeded casts.
> 
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>

Reviewed-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

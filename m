Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id D375C6B00AF
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 01:54:24 -0400 (EDT)
Message-ID: <4FD5880E.6070206@kernel.org>
Date: Mon, 11 Jun 2012 14:54:22 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH v3 07/10] mm: frontswap: remove unnecessary check during
 initialization
References: <1339325468-30614-1-git-send-email-levinsasha928@gmail.com> <1339325468-30614-8-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1339325468-30614-8-git-send-email-levinsasha928@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: dan.magenheimer@oracle.com, konrad.wilk@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/10/2012 07:51 PM, Sasha Levin wrote:

> The check whether frontswap is enabled or not is done in the API functions in
> the frontswap header, before they are passed to the internal
> double-underscored frontswap functions.
> 
> Remove the check from __frontswap_init for consistency.

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

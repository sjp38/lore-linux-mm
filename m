Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 8AB5C6B002B
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 17:29:49 -0400 (EDT)
Date: Tue, 25 Sep 2012 14:29:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 05/10] mm, util: Use dup_user to duplicate user memory
Message-Id: <20120925142948.6b062cb6.akpm@linux-foundation.org>
In-Reply-To: <1347137279-17568-5-git-send-email-elezegarcia@gmail.com>
References: <1347137279-17568-1-git-send-email-elezegarcia@gmail.com>
	<1347137279-17568-5-git-send-email-elezegarcia@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>

On Sat,  8 Sep 2012 17:47:54 -0300
Ezequiel Garcia <elezegarcia@gmail.com> wrote:

> Previously the strndup_user allocation was being done through memdup_user,
> and the caller was wrongly traced as being strndup_user
> (the correct trace must report the caller of strndup_user).
> 
> This is a common problem: in order to get accurate callsite tracing,
> a utils function can't allocate through another utils function,
> but instead do the allocation himself (or inlined).
> 
> Here we fix this by creating an always inlined dup_user() function to
> performed the real allocation and to be used by memdup_user and strndup_user.

This patch increases util.o's text size by 238 bytes.  A larger kernel
with a worsened cache footprint.

And we did this to get marginally improved tracing output?  This sounds
like a bad tradeoff to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8FD3B6B007E
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 14:05:32 -0500 (EST)
Message-ID: <4AEF2D78.5060607@redhat.com>
Date: Mon, 02 Nov 2009 14:05:28 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/11] Add get_user_pages() variant that fails if major
 fault is required.
References: <1257076590-29559-1-git-send-email-gleb@redhat.com> <1257076590-29559-6-git-send-email-gleb@redhat.com>
In-Reply-To: <1257076590-29559-6-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 11/01/2009 06:56 AM, Gleb Natapov wrote:
> This patch add get_user_pages() variant that only succeeds if getting
> a reference to a page doesn't require major fault.
>
> Signed-off-by: Gleb Natapov<gleb@redhat.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

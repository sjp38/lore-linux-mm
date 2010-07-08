Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BF43D6006F5
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 10:16:01 -0400 (EDT)
Message-ID: <4C35DD97.90103@redhat.com>
Date: Thu, 08 Jul 2010 10:15:51 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Add trace event for munmap
References: <1278597931-26855-1-git-send-email-emunson@mgebm.net>
In-Reply-To: <1278597931-26855-1-git-send-email-emunson@mgebm.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <emunson@mgebm.net>
Cc: akpm@linux-foundation.org, mingo@redhat.com, hugh.dickins@tiscali.co.uk, linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, anton@samba.org
List-ID: <linux-mm.kvack.org>

On 07/08/2010 10:05 AM, Eric B Munson wrote:
> This patch adds a trace event for munmap which will record the starting
> address of the unmapped area and the length of the umapped area.  This
> event will be used for modeling memory usage.

Sounds like a useful trace point to me.

> Signed-of-by: Eric B Munson<emunson@mgebm.net>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

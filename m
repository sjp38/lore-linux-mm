Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 57D8C6B004A
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 13:07:48 -0400 (EDT)
Message-ID: <4CAB5B52.4090404@redhat.com>
Date: Tue, 05 Oct 2010 13:07:30 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] filemap_fault: unique path for locking page
References: <1286265215-9025-1-git-send-email-walken@google.com> <1286265215-9025-2-git-send-email-walken@google.com>
In-Reply-To: <1286265215-9025-2-git-send-email-walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Ying Han <yinghan@google.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On 10/05/2010 03:53 AM, Michel Lespinasse wrote:
> This change introduces a single location where filemap_fault() locks
> the desired page. There used to be two such places, depending if the
> initial find_get_page() was successful or not.
>
> Signed-off-by: Michel Lespinasse<walken@google.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

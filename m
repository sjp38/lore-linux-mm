Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 403775F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 12:04:32 -0400 (EDT)
Message-ID: <49DB7934.3060008@redhat.com>
Date: Tue, 07 Apr 2009 12:03:00 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] [13/16] POISON: The high level memory error handler in
 the VM
References: <20090407509.382219156@firstfloor.org> <20090407151010.E72A91D0471@basil.firstfloor.org>
In-Reply-To: <20090407151010.E72A91D0471@basil.firstfloor.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: hugh@veritas.com, npiggin@suse.de, lee.schermerhorn@hp.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:

> This is rather tricky code and needs a lot of review. Undoubtedly it still
> has bugs.

It's just complex enough that it looks like it might have
more bugs, but I sure couldn't find any.

Hitting a bug in this code seems favorable to hitting
guaranteed memory corruption, so I hope Andrew or Ingo
will merge this into one of their trees.

> Signed-off-by: Andi Kleen <ak@linux.intel.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

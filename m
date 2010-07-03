Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 73B186B01AC
	for <linux-mm@kvack.org>; Sat,  3 Jul 2010 15:56:12 -0400 (EDT)
Message-ID: <4C2F95CF.4000308@redhat.com>
Date: Sat, 03 Jul 2010 22:55:59 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [Bugme-new] [Bug 16321] New: os unresponsive during buffered
 I/O
References: <bug-16321-10286@https.bugzilla.kernel.org/>	<20100702160501.45861821.akpm@linux-foundation.org>	<4C2F255D.6000908@kernel.dk> <20100703081613.36e1cba8.akpm@linux-foundation.org>
In-Reply-To: <20100703081613.36e1cba8.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/03/2010 06:16 PM, Andrew Morton wrote:
>
> My laptop goes absolutely utterly mouse-wont-move comatose for tens of
> minutes when it fetchmails 100 emails and 100 spamassassins go berzerk.
> It could be either a CPU scheduler thing, or an IO thing, or an evil
> combination of both.
>    

Try putting your spamassasins in a cgroup and see.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

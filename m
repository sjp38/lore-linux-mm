Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 88BA06B01F0
	for <linux-mm@kvack.org>; Fri, 14 May 2010 02:23:48 -0400 (EDT)
Received: by pva4 with SMTP id 4so1063708pva.14
        for <linux-mm@kvack.org>; Thu, 13 May 2010 23:23:47 -0700 (PDT)
Date: Fri, 14 May 2010 14:27:34 +0800
From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: /proc/<pid>/maps question....why aren't adjacent memory chunks
 merged?
Message-ID: <20100514062734.GA5612@cr0.nay.redhat.com>
References: <4BEC704C.9000709@nortel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BEC704C.9000709@nortel.com>
Sender: owner-linux-mm@kvack.org
To: Chris Friesen <cfriesen@nortel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 13, 2010 at 03:34:04PM -0600, Chris Friesen wrote:
>Hi,
>
>I've got a system running a somewhat-modified 2.6.27 on 64-bit x86.
>
>While investigating a userspace memory leak issue I noticed that
>/proc/<pid>/maps showed a bunch of adjacent anonymous memory chunks with
>identical permissions:
>
>7fd048000000-7fd04c000000 rw-p 00000000 00:00 0
>7fd04c000000-7fd050000000 rw-p 00000000 00:00 0
>7fd050000000-7fd054000000 rw-p 00000000 00:00 0
>7fd054000000-7fd058000000 rw-p 00000000 00:00 0
>7fd058000000-7fd05c000000 rw-p 00000000 00:00 0
>7fd05c000000-7fd060000000 rw-p 00000000 00:00 0
>7fd060000000-7fd064000000 rw-p 00000000 00:00 0
>7fd064000000-7fd068000000 rw-p 00000000 00:00 0
>7fd068000000-7fd06c000000 rw-p 00000000 00:00 0
>7fd06c000000-7fd070000000 rw-p 00000000 00:00 0
>7fd070000000-7fd074000000 rw-p 00000000 00:00 0
>7fd074000000-7fd078000000 rw-p 00000000 00:00 0
>7fd078000000-7fd07c000000 rw-p 00000000 00:00 0
>7fd07c000000-7fd07fffe000 rw-p 00000000 00:00 0
>
>I was under the impression that the kernel would merge areas together in
>this circumstance.  Does anyone have an idea about what's going on here?
>

Well, that is not so simple, there are other considerations,
you need to check vma_merge(), especially can_vma_merge_{after,before}().

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

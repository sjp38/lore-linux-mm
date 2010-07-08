Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A03616B024A
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 00:29:27 -0400 (EDT)
Message-ID: <4C355417.3020503@redhat.com>
Date: Thu, 08 Jul 2010 00:29:11 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 12/12] Send async PF when guest is not in userspace
 too.
References: <1278433500-29884-1-git-send-email-gleb@redhat.com> <1278433500-29884-13-git-send-email-gleb@redhat.com>
In-Reply-To: <1278433500-29884-13-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

On 07/06/2010 12:25 PM, Gleb Natapov wrote:
> Signed-off-by: Gleb Natapov<gleb@redhat.com>

This patch needs a commit message on the next submission.
Other than that:

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

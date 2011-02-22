Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D278F8D0039
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 03:38:32 -0500 (EST)
Message-ID: <4D637621.1000109@cn.fujitsu.com>
Date: Tue, 22 Feb 2011 16:38:57 +0800
From: Lai Jiangshan <laijs@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] KVM: Enable async page fault processing.
References: <1296559307-14637-1-git-send-email-gleb@redhat.com> <1296559307-14637-3-git-send-email-gleb@redhat.com>
In-Reply-To: <1296559307-14637-3-git-send-email-gleb@redhat.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gleb Natapov <gleb@redhat.com>, avi@redhat.com
Cc: mtosatti@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/-9/-28163 03:59 AM, Gleb Natapov wrote:
> If asynchronous hva_to_pfn() is requested call GUP with FOLL_NOWAIT to
> avoid sleeping on IO. Check for hwpoison is done at the same time,
> otherwise check_user_page_hwpoison() will call GUP again and will put
> vcpu to sleep.
> 
> Signed-off-by: Gleb Natapov <gleb@redhat.com>
> ---

Acked-by: Lai Jiangshan <laijs@cn.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

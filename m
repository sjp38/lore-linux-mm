Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 618CF8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 09:23:46 -0400 (EDT)
Message-ID: <4D8B45D9.10400@redhat.com>
Date: Thu, 24 Mar 2011 15:23:37 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] KVM: Enable async page fault processing.
References: <1296559307-14637-1-git-send-email-gleb@redhat.com> <1296559307-14637-3-git-send-email-gleb@redhat.com> <20110324122206.GE32408@redhat.com>
In-Reply-To: <20110324122206.GE32408@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gleb Natapov <gleb@redhat.com>
Cc: mtosatti@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/24/2011 02:22 PM, Gleb Natapov wrote:
> On Tue, Feb 01, 2011 at 01:21:47PM +0200, Gleb Natapov wrote:
> >  If asynchronous hva_to_pfn() is requested call GUP with FOLL_NOWAIT to
> >  avoid sleeping on IO. Check for hwpoison is done at the same time,
> >  otherwise check_user_page_hwpoison() will call GUP again and will put
> >  vcpu to sleep.
> >
> FOLL_NOWAIT is now in Linus tree, so this patch can be applied now. I
> verified that it still applies and works.

Thanks, applied and queued for 2.6.39.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

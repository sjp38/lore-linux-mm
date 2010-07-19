Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2FA036006B4
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 15:53:07 -0400 (EDT)
Message-ID: <4C44AD0B.4090802@redhat.com>
Date: Mon, 19 Jul 2010 15:52:43 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 03/12] Add async PF initialization to PV guest.
References: <1279553462-7036-1-git-send-email-gleb@redhat.com> <1279553462-7036-4-git-send-email-gleb@redhat.com>
In-Reply-To: <1279553462-7036-4-git-send-email-gleb@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

On 07/19/2010 11:30 AM, Gleb Natapov wrote:
> Enable async PF in a guest if async PF capability is discovered.
>
> Signed-off-by: Gleb Natapov<gleb@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id DA1326B004D
	for <linux-mm@kvack.org>; Thu, 24 Sep 2009 12:02:51 -0400 (EDT)
Message-ID: <4ABB99FE.3060105@redhat.com>
Date: Thu, 24 Sep 2009 19:10:38 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] ksm: change default values to better fit into mainline
 kernel
References: <1253736347-3779-1-git-send-email-ieidus@redhat.com> <Pine.LNX.4.64.0909241644110.16561@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0909241644110.16561@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On 09/24/2009 06:52 PM, Hugh Dickins wrote:
> You rather caught me by surprise with this one, Izik: I was thinking
> more rc7 than rc1 for switching it off;

I thought that after the merge window -> only fixes can get in, but I 
guess I was wrong...

> +#else
> +	ksm_run = KSM_RUN_MERGE;	/* no way for user to start it */
> +
>    

That is a good point, didnt notice that I am blocking the usage of it 
when sysfs is not build.

>   #endif /* CONFIG_SYSFS */
>
>   	return 0;
>    

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 2D39F6B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 17:04:27 -0400 (EDT)
Message-ID: <51F0414F.3060600@sr71.net>
Date: Wed, 24 Jul 2013 14:04:15 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] Drivers: hv: balloon: Online the hot-added memory
 "in context"
References: <1374701355-30799-1-git-send-email-kys@microsoft.com> <1374701399-30842-1-git-send-email-kys@microsoft.com> <1374701399-30842-2-git-send-email-kys@microsoft.com>
In-Reply-To: <1374701399-30842-2-git-send-email-kys@microsoft.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "K. Y. Srinivasan" <kys@microsoft.com>
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com, andi@firstfloor.org, akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyuki@gmail.com, mhocko@suse.cz, hannes@cmpxchg.org, yinghan@google.com

On 07/24/2013 02:29 PM, K. Y. Srinivasan wrote:
>  		/*
> -		 * Wait for the memory block to be onlined.
> -		 * Since the hot add has succeeded, it is ok to
> -		 * proceed even if the pages in the hot added region
> -		 * have not been "onlined" within the allowed time.
> +		 * Before proceeding to hot add the next segment,
> +		 * online the segment that has been hot added.
>  		 */
> -		wait_for_completion_timeout(&dm_device.ol_waitevent, 5*HZ);
> +		online_memory_block(start_pfn);

Ahhhhh....  You've got a timeout in the code in order to tell the
hypervisor that you were successfully able to add the memory?  The
userspace addition code probably wasn't running within this timeout
period.  right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

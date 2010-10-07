Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 92F876B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 20:32:02 -0400 (EDT)
Date: Thu, 7 Oct 2010 09:27:41 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 2/4] HWPOISON: Copy si_addr_lsb to user
Message-ID: <20101007002741.GA9891@spritzera.linux.bs1.fc.nec.co.jp>
References: <1286398141-13749-1-git-send-email-andi@firstfloor.org>
 <1286398141-13749-3-git-send-email-andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <1286398141-13749-3-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, fengguang.wu@intel.com, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>
List-ID: <linux-mm.kvack.org>

Just nitpicking...

> @@ -2215,6 +2215,14 @@ int copy_siginfo_to_user(siginfo_t __user *to, siginfo_t *from)
>  #ifdef __ARCH_SI_TRAPNO
>  		err |= __put_user(from->si_trapno, &to->si_trapno);
>  #endif
> +#ifdef BUS_MCEERR_AO
> +		/* 
                  ^
                  trailing white space
> +		 * Other callers might not initialize the si_lsb field,
> +	 	 * so check explicitely for the right codes here.
        ^                   ^^^^^^^^^^^
        white space         explicitly

> +		 */
> +		if (from->si_code == BUS_MCEERR_AR || from->si_code == BUS_MCEERR_AO)
> +			err |= __put_user(from->si_addr_lsb, &to->si_addr_lsb);
> +#endif
>  		break;
>  	case __SI_CHLD:
>  		err |= __put_user(from->si_pid, &to->si_pid);

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

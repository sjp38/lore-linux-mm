Date: Fri, 21 Nov 2003 15:01:08 -0600
From: Matt Mackall <mpm@selenic.com>
Subject: Re: 2.6.0-test9-mm5
Message-ID: <20031121210108.GJ22139@waste.org>
References: <20031121121116.61db0160.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20031121121116.61db0160.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Nov 21, 2003 at 12:11:16PM -0800, Andrew Morton wrote:
> 
> +4g4g-athlon-triplefault-fix.patch
> 
>  Fix triplefaults when starting X on athlons with the 4G/4G plit enabled.

For the record, Zwane and I reproduced this on K6, Opteron, P4, and
Xeon. In fact, the one machine I couldn't trigger the bug on was an
Athlon.

-- 
Matt Mackall : http://www.selenic.com : Linux development and consulting
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

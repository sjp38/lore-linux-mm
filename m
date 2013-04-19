Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 5BEC96B0070
	for <linux-mm@kvack.org>; Thu, 18 Apr 2013 22:45:02 -0400 (EDT)
Message-ID: <5170AFAC.9050602@linux.intel.com>
Date: Thu, 18 Apr 2013 19:45:00 -0700
From: Darren Hart <dvhart@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] futex: bugfix for futex-key conflict when futex use hugepage
References: <OF79A40956.94F46B9C-ON48257B50.00320F73-48257B50.0036925D@zte.com.cn> <516EAF31.8000107@linux.intel.com> <516EBF23.2090600@sr71.net> <516EC508.6070200@linux.intel.com> <OF7B3DF162.973A9AD7-ON48257B51.00299512-48257B51.002C7D65@zte.com.cn> <51700475.7050102@linux.intel.com> <OFD8FA3C9D.ACFCFB28-ON48257B52.0008A691-48257B52.000C4DFB@zte.com.cn>
In-Reply-To: <OFD8FA3C9D.ACFCFB28-ON48257B52.0008A691-48257B52.000C4DFB@zte.com.cn>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhang.yi20@zte.com.cn
Cc: Dave Hansen <dave@sr71.net>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>

> 
> BTW, have you seen the testcase in my other mail?  It seems to be rejected 
> by LKML.
> 

I did not receive it, did you also CC me?

-- 
Darren Hart
Intel Open Source Technology Center
Yocto Project - Technical Lead - Linux Kernel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 62E416B0081
	for <linux-mm@kvack.org>; Tue,  8 May 2012 13:35:53 -0400 (EDT)
Message-ID: <4FA95976.9050900@linux.intel.com>
Date: Tue, 08 May 2012 10:35:50 -0700
From: "H. Peter Anvin" <hpa@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] Expand memblock=debug to provide a bit more details
 (v1).
References: <1336157382-14548-1-git-send-email-konrad.wilk@oracle.com> <CAE9FiQWOps3Hmw=p6mWObRnu2KHVNshpoY+uWcAAQd1Yxi54yQ@mail.gmail.com> <20120504192459.GA5684@phenom.dumpdata.com>
In-Reply-To: <20120504192459.GA5684@phenom.dumpdata.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Yinghai Lu <yinghai@kernel.org>, linux-kernel@vger.kernel.org, tj@kernel.org, paul.gortmaker@windriver.com, akpm@linux-foundation.org, linux-mm@kvack.org

On 05/04/2012 12:24 PM, Konrad Rzeszutek Wilk wrote:
>>
>> that RET_IP is not very helpful for debugging.
> 
> Is there a better way of doing it that is automatic?
>>

It depends on what "it" is.  You could do a full stack backtrace, or use
__builtin_return_address(N).

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id CC6026B0073
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 03:32:17 -0400 (EDT)
Message-ID: <520B3240.6030208@zytor.com>
Date: Wed, 14 Aug 2013 00:31:12 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] mm: Unify pte_to_pgoff and pgoff_to_pte helpers
References: <20130814070059.GJ2869@moon> <520B303D.2090206@zytor.com> <20130814072453.GK2869@moon>
In-Reply-To: <20130814072453.GK2869@moon>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Pavel Emelyanov <xemul@parallels.com>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Peter Zijlstra <peterz@infradead.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>

On 08/14/2013 12:24 AM, Cyrill Gorcunov wrote:
> On Wed, Aug 14, 2013 at 12:22:37AM -0700, H. Peter Anvin wrote:
>> On 08/14/2013 12:00 AM, Cyrill Gorcunov wrote:
>>> +#define pte_bfop(v,r,m,l)	((((v) >> (r)) & (m)) << (l))
>>
>> "bfop"?
> 
> B_it_F_ield_OP_eration, Peter I don't mind to use any other
> name, this was just short enough to type.
> 

I think it would be useful to have a comment what it means and what
v,r,m,l represent.

Perhaps m should be mask width rather than the actual mask?

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

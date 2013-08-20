Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 2D2686B0033
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 13:25:28 -0400 (EDT)
Message-ID: <5213A677.4030203@infradead.org>
Date: Tue, 20 Aug 2013 10:25:11 -0700
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] docs: Document soft dirty behaviour for freshly created
 memory regions
References: <20130820153132.GK18673@moon> <5213A002.7020408@infradead.org> <20130820170105.GM18673@moon>
In-Reply-To: <20130820170105.GM18673@moon>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, Pavel Emelyanov <xemul@parallels.com>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Peter Zijlstra <peterz@infradead.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

On 08/20/13 10:01, Cyrill Gorcunov wrote:
> On Tue, Aug 20, 2013 at 09:57:38AM -0700, Randy Dunlap wrote:
>>>  
>>> +  While in most cases tracking memory changes by #PF-s is more than enough
>>                                                                        enough,
> 
> ?

Long introductory phrases usually merit a comma after them.

> 
> For the rest -- thanks a LOT Randy, I'll update.
> --



-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

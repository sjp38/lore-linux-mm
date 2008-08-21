Received: by py-out-1112.google.com with SMTP id f31so526577pyh.20
        for <linux-mm@kvack.org>; Thu, 21 Aug 2008 00:18:00 -0700 (PDT)
Message-ID: <2f11576a0808210018h157b0eddr1c327ecad8315cad@mail.gmail.com>
Date: Thu, 21 Aug 2008 16:18:00 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 2/2] quicklist shouldn't be proportional to # of CPUs
In-Reply-To: <20080821.001322.236658980.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080820195021.12E7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080820200709.12F0.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080820234615.258a9c04.akpm@linux-foundation.org>
	 <20080821.001322.236658980.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux-foundation.org, tokunaga.keiich@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

>> sparc64 allmodconfig:
>>
>> mm/quicklist.c: In function `max_pages':
>> mm/quicklist.c:44: error: invalid lvalue in unary `&'
>>
>> we seem to have a made a spectacular mess of cpumasks lately.
>
> It should explode similarly on x86, since it also defines node_to_cpumask()
> as an inline function.
>
> IA64 seems to be one of the few platforms to define this as a macro
> evaluating to the node-to-cpumask array entry, so it's clear what
> platform Motohiro-san did build testing on :-)

Thank you good advice.
I don't have sparc64 machine but I can get borrowing x86 machine.
So, I'll test on x86 today.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

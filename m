Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id DE8FD6B002C
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 15:08:12 -0500 (EST)
Message-ID: <4F578BCA.1090706@jp.fujitsu.com>
Date: Wed, 07 Mar 2012 11:24:42 -0500
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch] mm, mempolicy: make mempolicies robust against errors
References: <alpine.DEB.2.00.1203041341340.9534@chino.kir.corp.google.com> <20120306160833.0e9bf50a.akpm@linux-foundation.org> <alpine.DEB.2.00.1203061950050.24600@chino.kir.corp.google.com> <alpine.DEB.2.00.1203062025490.24600@chino.kir.corp.google.com> <CAHGf_=qG1Lah00fGTNENvtgacsUt1=FcMKyt+kmPG1=UD6ecNw@mail.gmail.com> <alpine.DEB.2.00.1203062151530.6424@chino.kir.corp.google.com> <4F570168.6050008@gmail.com> <alpine.DEB.2.00.1203062253150.1427@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1203062253150.1427@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: kosaki.motohiro@gmail.com, kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org

On 3/7/2012 1:56 AM, David Rientjes wrote:
> On Wed, 7 Mar 2012, KOSAKI Motohiro wrote:
> 
>> So, I strongly suggest to remove CONFIG_BUG=n. It is neglected very long time
>> and
>> much plenty code assume BUG() is not no-op. I don't think we can fix all
>> place.
>>
>> Just one instruction don't hurt code size nor performance.
> 
> It's a different topic, the proposal here is whether an error in 
> mempolicies (either the code or flipped bit) should crash the kernel or 
> not since it's a condition that can easily be recovered from and leave 
> BUG() to errors that actually are fatal.  Crashing the kernel offers no 
> advantage.

Should crash? The code path never reach. thus there is no ideal behavior.
In this case, BUG() is just unreachable annotation. So let's just annotate
unreachable() even though CONFIG_BUG=n.

WARN_ON_ONCE makes code broat and no positive impact.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

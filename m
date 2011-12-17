Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id E6CBC6B004F
	for <linux-mm@kvack.org>; Sat, 17 Dec 2011 15:55:45 -0500 (EST)
Received: by wibhq12 with SMTP id hq12so664596wib.14
        for <linux-mm@kvack.org>; Sat, 17 Dec 2011 12:55:44 -0800 (PST)
Message-ID: <1324155340.3323.23.camel@edumazet-laptop>
Subject: Re: Memory corruption warnings triggered by repeated slabinfo -v
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 17 Dec 2011 21:55:40 +0100
In-Reply-To: <4EECF64B.1020409@palosanto.com>
References: <4EEBFAF3.60609@palosanto.com>
	 <1324092514.2621.49.camel@edumazet-laptop> <4EECF64B.1020409@palosanto.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex =?ISO-8859-1?Q?Villac=EDs?= Lasso <a_villacis@palosanto.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Le samedi 17 dA(C)cembre 2011 A  15:06 -0500, Alex VillacA-s Lasso a A(C)crit :
> El 16/12/11 22:28, Eric Dumazet escribiA3:
> > Le vendredi 16 dA(C)cembre 2011 A  21:14 -0500, Alex VillacA-s Lasso a
> > A(C)crit :
> >> I am running Fedora 16 x86_64 and testing vanilla kernel 3.2-rc5. I
> >> wanted to test the slabinfo program, so I wrote a small shell script
> >> slabinfo-forever.sh (attached) that invokes slabinfo -v every 3 seconds.
> >> Just by doing this, I was able to trigger several memory validation
> >> warnings, attached in this message. The reason I wanted to test slabinfo
> >> is because back when I was running Fedora 14, I had some video issues
> >> that seemed consistent with memory corruption. I tried to submit a
> >> kernel bug at https://bugzilla.kernel.org/show_bug.cgi?id=42312 just
> >> before the kernel.org hack issue, but bugzilla.kernel.org never came up
> >> after that.
> > Problem is known and fixes were submitted.
> >
> >
> Still happening in 3.2-rc6. The dmesg output is attached.
> 
> What are the git commits of the fixes? Are they scheduled to go into 3.2 
> stable?

Fixes were submitted but not yet accepted in mainline.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

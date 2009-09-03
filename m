Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1123A6B004F
	for <linux-mm@kvack.org>; Thu,  3 Sep 2009 11:34:43 -0400 (EDT)
Message-ID: <4A9FE3E0.8050208@redhat.com>
Date: Thu, 03 Sep 2009 18:42:24 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: improving checksum cpu consumption in ksm
References: <4A983C52.7000803@redhat.com> <Pine.LNX.4.64.0908312233340.23516@sister.anvils> <4A9FB83F.2000605@redhat.com> <Pine.LNX.4.64.0909031535290.13918@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0909031535290.13918@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> Yes, that's nice, thank you for looking into it.
>
> But please do some more along these lines, if you've time?
> Presumably the improvement from Jenkins lookup2 to lookup3
> is therefore more than 15%, but we cannot tell how much.
>
> I think you need to do a run with a null version of jhash2(),
> one just returning 0 or 0xffffffff (the first would settle down
> a little quicker because oldchecksum 0 will match the first time;
> but there should be no difference once you cut out settling time).
>
> And a run with an almost-null version of jhash2(), one which does
> also read the whole page sequentially into cache, so we can see
> how much is the processing and how much is the memory access.
>
> And also, while you're about it, a run with cmp_and_merge_page()
> stubbed out, so we can see how much is just the page table walking
> (and deduce from that how much is the radix tree walking and memcmping).
>
> Hmm, and a run to see how much is radix tree walking,
> by stubbing out the memcmping.
>
> Sorry... if you (or someone else following) have the time!
>   

Good ideas, The tests that I did were quick tests, I hope in Saturday 
(or maybe few days after it) I will have more time to spend on this area
I will try to collect and see how much every part is taking there.
So i will keep benchmarking it in terms of "how many loops it accomplish"

>
> Doesn't matter to your results, so long as it didn't crash;
> but I think you meant to say
>
>      p = (unsigned char *)(((unsigned long)p + 4095) & ~4095);
>      p_end = p + 1024 * 1024 * 100;
>   

Yes...


Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A04728D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 18:02:50 -0500 (EST)
Message-ID: <4D6ECC94.4080603@cesarb.net>
Date: Wed, 02 Mar 2011 20:02:44 -0300
From: Cesar Eduardo Barros <cesarb@cesarb.net>
MIME-Version: 1.0
Subject: Re: [PATCHv2 13/24] sys_swapon: separate bdev claim and inode lock
References: <4D6D7FEA.80800@cesarb.net> <1299022128-6239-1-git-send-email-cesarb@cesarb.net> <1299022128-6239-14-git-send-email-cesarb@cesarb.net> <20110302214019.GB2864@mgebm.net>
In-Reply-To: <20110302214019.GB2864@mgebm.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@mgebm.net>
Cc: linux-mm@kvack.org

Em 02-03-2011 18:40, Eric B Munson escreveu:
>> -	} else {
>> -		error = -EINVAL;
>> +	error = claim_swapfile(p, inode);
>> +	if (unlikely(error))
>
> As a personal preference, I don't use likely/unlikley unless I have a profiler
> telling me that the compiler got it wrong.  Just a suggestion.

I tend to use them for paths which should never happen in normal 
operation (error paths mostly). But yeah, I am probably still overusing 
them - who says the error path is not normal in some cases? Old habits 
die hard...

And I added more unlikely() calls than are visible in the patches. 
Remember that every IS_ERR() counts as a unlikely() too.

-- 
Cesar Eduardo Barros
cesarb@cesarb.net
cesar.barros@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

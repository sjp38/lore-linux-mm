Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E3FF090011E
	for <linux-mm@kvack.org>; Mon, 16 May 2011 17:29:09 -0400 (EDT)
Received: by pwi12 with SMTP id 12so3225142pwi.14
        for <linux-mm@kvack.org>; Mon, 16 May 2011 14:29:06 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 3/3] checkpatch.pl: Add check for task comm references
References: <1305580757-13175-1-git-send-email-john.stultz@linaro.org>
 <1305580757-13175-4-git-send-email-john.stultz@linaro.org>
Date: Mon, 16 May 2011 23:29:02 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.vvlfaobx3l0zgt@mnazarewicz-glaptop>
In-Reply-To: <1305580757-13175-4-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, John Stultz <john.stultz@linaro.org>
Cc: Ted Ts'o <tytso@mit.edu>, Jiri Slaby <jirislaby@gmail.com>, KOSAKI
 Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew
 Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Mon, 16 May 2011 23:19:17 +0200, John Stultz wrote:
> Now that accessing current->comm needs to be protected,
> @@ -2868,6 +2868,10 @@ sub process {
>  			WARN("usage of NR_CPUS is often wrong - consider using  
> cpu_possible(), num_possible_cpus(), for_each_possible_cpu(), etc\n" .  
> $herecurr);
>  		}
> +# check for current->comm usage
> +		if ($line =~ /\b(?:current|task|tsk|t)\s*->\s*comm\b/) {

Not a checkpatch.pl expert but as far as I'm concerned, that looks  
reasonable.

I was sort of worried that t->comm could produce quite a few false  
positives
but all its appearances in the kernel (seem to) refer to task.

> +			WARN("comm access needs to be protected. Use get_task_comm, or  
> printk's \%ptc formatting.\n" . $herecurr);
> +		}
>  # check for %L{u,d,i} in strings
>  		my $string;
>  		while ($line =~ /(?:^|")([X\t]*)(?:"|$)/g) {


-- 
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=./ `o
..o | Computer Science,  Michal "mina86" Nazarewicz    (o o)
ooo +-----<email/xmpp: mnazarewicz@google.com>-----ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 907366B0025
	for <linux-mm@kvack.org>; Tue, 17 May 2011 17:04:50 -0400 (EDT)
Received: by pvc12 with SMTP id 12so555045pvc.14
        for <linux-mm@kvack.org>; Tue, 17 May 2011 14:04:46 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 3/3] checkpatch.pl: Add check for task comm references
References: <1305665263-20933-1-git-send-email-john.stultz@linaro.org>
 <1305665263-20933-4-git-send-email-john.stultz@linaro.org>
Date: Tue, 17 May 2011 23:04:42 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.vvm8t4xg3l0zgt@mnazarewicz-glaptop>
In-Reply-To: <1305665263-20933-4-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, John Stultz <john.stultz@linaro.org>
Cc: Joe Perches <joe@perches.com>, Andy Whitcroft <apw@canonical.com>, Jiri Slaby <jirislaby@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, 17 May 2011 22:47:43 +0200, John Stultz wrote:
> diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
> index d867081..a67ea69 100755
> --- a/scripts/checkpatch.pl
> +++ b/scripts/checkpatch.pl
> @@ -2868,6 +2868,13 @@ sub process {
>  			WARN("usage of NR_CPUS is often wrong - consider using  
> cpu_possible(), num_possible_cpus(), for_each_possible_cpu(), etc\n" .  
> $herecurr);
>  		}
> +# check for current->comm usage
> +		our $common_comm_vars = qr{(?x:

It should by "my" not "our".

> +		        current|tsk|p|task|curr|chip|t|object|me
> +		)};

Also, I would stick it on a single line, ie.:

		my $comm_vars = qr/current|tsk|p|task|curr|chip|t|object|me/;

> +		if ($line =~ /\b($common_comm_vars)\s*->\s*comm\b/) {

The parens are not needed.

> +			WARN("comm access needs to be protected. Use get_task_comm, or  
> printk's \%ptc formatting.\n" . $herecurr);
> +		}

Empty line should be here.

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

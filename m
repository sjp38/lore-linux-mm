From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <27043861.1213277688814.kamezawa.hiroyu@jp.fujitsu.com>
Date: Thu, 12 Jun 2008 22:34:48 +0900 (JST)
Subject: Re: Re: [RFD][PATCH] memcg: Move Usage at Task Move
In-Reply-To: <20080612131748.GB8453@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <20080612131748.GB8453@us.ibm.com>
 <20080606105235.3c94daaf.kamezawa.hiroyu@jp.fujitsu.com> <6599ad830806110017t5ebeda78id1914d179a018422@mail.gmail.com> <20080611164544.94047336.kamezawa.hiroyu@jp.fujitsu.com> <6599ad830806110104n99cdc7h80063e91d16bf0a5@mail.gmail.com> <20080611172714.018aa68c.kamezawa.hiroyu@jp.fujitsu.com> <6599ad830806110148v65df67f8ge0ccdd56c21c89e0@mail.gmail.com> <20080612140806.dc161c77.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>, yamamoto@valinux.co.jp, nishimura@mxp.nes.nec.co.jp, linux-mm@kvack.org, containers@lists.osdl.org, balbir@linux.vnet.ibm.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

----- Original Message -----
>> Just a question:
>> What happens when a thread (not thread-group-leader) changes its ns by
>> ns-cgroup ? not-allowed ?
>
>I don't quite understand the question.  I assume you're asking whether
>your cgroup, when composed with ns, will refuse a task in cgroup /cg/1/2
>from being able to
>
>	mkdir /cg/1/2/3
>	echo $$ > /cg/1/2/3/tasks
>
>or
>
>	unshare(CLONE_NEWNS)
>
>which the ns cgroup would allow, and what your cgroup would do in that
>case.  If your question ("not-allowed ?") is about ns cgroup behavior
>then please rephrase.

Ah, sorry. I'm just curious. (and I should read the code before making
quiestion.)

Assume a thread group contains threadA, threadB, threadC.

I wanted to ask "Can threadA, and threadB, and threadC
be in different cgroups ? And if so, how ns cgroup handles it ?"

Maybe I don't understand ns cgroup.

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

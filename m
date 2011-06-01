Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 532AF6B004A
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 19:10:07 -0400 (EDT)
Received: by bwz17 with SMTP id 17so769267bwz.14
        for <linux-mm@kvack.org>; Wed, 01 Jun 2011 16:10:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DE66BEB.7040502@redhat.com>
References: <1306925044-2828-1-git-send-email-imammedo@redhat.com>
	<20110601123913.GC4266@tiehlicka.suse.cz>
	<4DE6399C.8070802@redhat.com>
	<20110601134149.GD4266@tiehlicka.suse.cz>
	<4DE64F0C.3050203@redhat.com>
	<20110601152039.GG4266@tiehlicka.suse.cz>
	<4DE66BEB.7040502@redhat.com>
Date: Thu, 2 Jun 2011 08:10:04 +0900
Message-ID: <BANLkTimbqHPeUdue=_Z31KVdPwcXtbLpeg@mail.gmail.com>
Subject: Re: [PATCH] memcg: do not expose uninitialized mem_cgroup_per_node to world
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Mammedov <imammedo@redhat.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, balbir@linux.vnet.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org

>pc = list_entry(list->prev, struct page_cgroup, lru);

Hmm, I disagree your patch is a fix for mainline. At least, a cgroup
before completion of
create() is not populated to userland and you never be able to rmdir()
it because you can't
find it.


 >26:   e8 7d 12 30 00          call   0x3012a8
 >2b:*  8b 73 08                mov    0x8(%ebx),%esi     <-- trapping
instruction
 >2e:   8b 7c 24 24             mov    0x24(%esp),%edi
 >32:   8b 07                   mov    (%edi),%eax

Hm, what is the call 0x3012a8 ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

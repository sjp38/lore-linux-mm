Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id CB7AA6B004D
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 23:55:04 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so410824pbb.14
        for <linux-mm@kvack.org>; Tue, 31 Jul 2012 20:55:04 -0700 (PDT)
Date: Tue, 31 Jul 2012 20:55:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] memcg, oom: Clarify some oom dump messages
In-Reply-To: <1343146334-15161-1-git-send-email-handai.szj@taobao.com>
Message-ID: <alpine.DEB.2.00.1207312052070.20073@chino.kir.corp.google.com>
References: <1343146160-15012-1-git-send-email-handai.szj@taobao.com> <1343146334-15161-1-git-send-email-handai.szj@taobao.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, mhocko@suse.cz, gthelen@google.com, hannes@cmpxchg.org

On Wed, 25 Jul 2012, Sha Zhengju wrote:

> From: Sha Zhengju <handai.szj@taobao.com>
> 
> Revise some oom dump messages to avoid misleading admin.
> 

The only place the oom killer emits information on what it does via the 
kernel log so changing this has the potential for messing up a number of 
scripts that people are using for parsing it (this would break some of our 
log scraping code, for instance).

This adds nothing except a bogus message that is emitted when 
select_bad_process() races with oom_kill_process() and no kill occurs 
because all threads of the selected process have detached their mm.

Nack.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

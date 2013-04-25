Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id C49D76B0002
	for <linux-mm@kvack.org>; Thu, 25 Apr 2013 10:53:05 -0400 (EDT)
Date: Thu, 25 Apr 2013 16:49:55 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] oom: add pending SIGKILL check for chosen victim
Message-ID: <20130425144955.GA26368@redhat.com>
References: <1366643184-3627-1-git-send-email-dserrg@gmail.com> <20130422195138.GB31098@dhcp22.suse.cz> <20130423192614.c8621a7fe1b5b3e0a2ebf74a@gmail.com> <20130423155638.GJ8001@dhcp22.suse.cz> <20130424145514.GA24997@redhat.com> <20130424152236.GB7600@dhcp22.suse.cz> <20130424154216.GA27929@redhat.com> <20130424123311.79614649c6a7951d9f8a39fe@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130424123311.79614649c6a7951d9f8a39fe@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, dserrg <dserrg@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Sha Zhengju <handai.szj@taobao.com>

On 04/24, Andrew Morton wrote:
>
> Where does this leave us with Sergey's patch?  "Still good, but
> requires new changelog"?

Sergey is certainly right, this needs the fixes (thanks Sergey!).

But afaics the patch can't help, we need another solution.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

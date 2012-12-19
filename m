Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id CA46A6B002B
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 06:58:45 -0500 (EST)
Received: by mail-ob0-f181.google.com with SMTP id oi10so1877839obb.12
        for <linux-mm@kvack.org>; Wed, 19 Dec 2012 03:58:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121218172155.GC25208@dhcp22.suse.cz>
References: <1355742187-4111-1-git-send-email-handai.szj@taobao.com>
	<20121218172155.GC25208@dhcp22.suse.cz>
Date: Wed, 19 Dec 2012 19:58:44 +0800
Message-ID: <CAFj3OHWG9=sXwr3czHS_eB8Udn_x9afxdS9ScyaNTOMB_foj7g@mail.gmail.com>
Subject: Re: [PATCH V4] memcg, oom: provide more precise dump info while memcg
 oom happening
From: Sha Zhengju <handai.szj@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, linux-mm@kvack.org, Sha Zhengju <handai.szj@taobao.com>

On Wed, Dec 19, 2012 at 1:21 AM, Michal Hocko <mhocko@suse.cz> wrote:
> The patch doesn't apply cleanly on top of the current mm tree. The
> resolving is trivial but please make sure you work on top of the latest
> mmotm tree (or -mm git tree since-3.7 branch at the moment).
>

Oh, sorry for the trial, I'll rebase it on -mm since-3.7 branch.

> This also touches mm/oom_kill.c so please add David into the CC list.
>
> More comments below.
>

OK. Next version soon will fix these issues you've mentioned.

Thanks for reviewing!


Regards,
Sha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

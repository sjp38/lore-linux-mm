Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id A05236B002C
	for <linux-mm@kvack.org>; Sun,  5 Feb 2012 05:52:17 -0500 (EST)
Received: by bkbzs2 with SMTP id zs2so5330091bkb.14
        for <linux-mm@kvack.org>; Sun, 05 Feb 2012 02:52:15 -0800 (PST)
Message-ID: <4F2E5F5C.2080207@openvz.org>
Date: Sun, 05 Feb 2012 14:52:12 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] mm: convert rcu_read_lock() to srcu_read_lock(),
 thus allowing to sleep in callbacks
References: <y> <4f25649b.8253b40a.3800.319d@mx.google.com> <4F2E5853.2060605@mellanox.com>
In-Reply-To: <4F2E5853.2060605@mellanox.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sagig <sagig@mellanox.com>
Cc: "aarcange@redhat.com" <aarcange@redhat.com>, "gleb@redhat.com" <gleb@redhat.com>, "oren@mellanox.com" <oren@mellanox.com>, "ogerlitz@mellanox.com" <ogerlitz@mellanox.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

sagig wrote:
> Hey all,
>
> I've published this patch [requested for comments] last week, But got no
> responses.
> Since I'm not sure what to do if  init_srcu_struct() call fails (it
> might due to memory pressure), I'm interested in the community's advice
> on how to act.
>
> Thanks,
>

Your patch is completely wrong.
There must be one shared srcu_struct structure.
Please read how rcu works in Documentation/RCU/

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

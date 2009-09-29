Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7A5906B005A
	for <linux-mm@kvack.org>; Tue, 29 Sep 2009 18:52:59 -0400 (EDT)
Message-ID: <4AC291B9.4060204@librato.com>
Date: Tue, 29 Sep 2009 19:01:13 -0400
From: Oren Laadan <orenl@librato.com>
MIME-Version: 1.0
Subject: Re: [PATCH v18 49/80] c/r: support for UTS namespace
References: <1253749920-18673-1-git-send-email-orenl@librato.com> <1253749920-18673-50-git-send-email-orenl@librato.com> <200909292213.21266@blacky.localdomain>
In-Reply-To: <200909292213.21266@blacky.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Nikita V. Youshchenko" <yoush@cs.msu.su>
Cc: Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>, Dan Smith <danms@us.ibm.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>



Nikita V. Youshchenko wrote:
>> +static struct uts_namespace *do_restore_uts_ns(struct ckpt_ctx *ctx)
>> ...
>> +#ifdef CONFIG_UTS_NS
>> +	uts_ns = create_uts_ns();
>> +	if (!uts_ns) {
>> +		uts_ns = ERR_PTR(-ENOMEM);
>> +		goto out;
>> +	}
>> +	down_read(&uts_sem);
>> +	name = &uts_ns->name;
>> +	memcpy(name->sysname, h->sysname, sizeof(name->sysname));
>> +	memcpy(name->nodename, h->nodename, sizeof(name->nodename));
>> +	memcpy(name->release, h->release, sizeof(name->release));
>> +	memcpy(name->version, h->version, sizeof(name->version));
>> +	memcpy(name->machine, h->machine, sizeof(name->machine));
>> +	memcpy(name->domainname, h->domainname, sizeof(name->domainname));
>> +	up_read(&uts_sem);
> 
> Could you please explain what for is this down_read() / up_read() ?
> You operate only on local objects: 'name' points to just-created 
> uts_ns, 'h' is also local data.

Nothing more than symmetry with checkpoint code, and a pedagogical
aspect...

Can be replaced by a suitable comment.

Oren.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

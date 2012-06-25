Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id A46C26B03A1
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 18:33:03 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so9060252lbj.14
        for <linux-mm@kvack.org>; Mon, 25 Jun 2012 15:33:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FE8E632.70602@parallels.com>
References: <1340633728-12785-1-git-send-email-glommer@parallels.com>
	<1340633728-12785-2-git-send-email-glommer@parallels.com>
	<20120625174437.GC3869@google.com>
	<4FE8E632.70602@parallels.com>
Date: Mon, 25 Jun 2012 15:33:01 -0700
Message-ID: <CAOS58YNV+uYbGYweSpQNSaRG8ixTG1ugTn42CfuAMO=S2ch6nw@mail.gmail.com>
Subject: Re: [PATCH 01/11] memcg: Make it possible to use the stock for more
 than one page.
From: Tejun Heo <tj@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Suleiman Souhlal <suleiman@google.com>

Hello,

On Mon, Jun 25, 2012 at 3:29 PM, Glauber Costa <glommer@parallels.com> wrot=
e:
>> It would be nice to explain why this is being done. =A0Just a simple
>> statement like - "prepare for XXX" or "will be needed by XXX".
>
>
> I picked this patch from Suleiman Souhlal, and tried to keep it as close =
as
> possible to his version.
>
> But for the sake of documentation, I can do that, yes.

Yeah, that would be great. Also, the patch does change behavior,
right? Explaining / justifying that a bit would be nice too.

Thanks!

--=20
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

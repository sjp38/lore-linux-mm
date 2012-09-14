Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id E2C4C6B0206
	for <linux-mm@kvack.org>; Fri, 14 Sep 2012 07:39:07 -0400 (EDT)
Message-ID: <50531696.1080708@parallels.com>
Date: Fri, 14 Sep 2012 15:35:50 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] memcg: clean up networking headers file inclusion
References: <20120914112118.GG28039@dhcp22.suse.cz> <50531339.1000805@parallels.com> <20120914113400.GI28039@dhcp22.suse.cz>
In-Reply-To: <20120914113400.GI28039@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Sachin
 Kamat <sachin.kamat@linaro.org>

On 09/14/2012 03:34 PM, Michal Hocko wrote:
> On Fri 14-09-12 15:21:29, Glauber Costa wrote:
>> On 09/14/2012 03:21 PM, Michal Hocko wrote:
>>> Hi,
>>> so I did some more changes to ifdefery of sock kmem part. The patch is
>>> below.=20
>>> Glauber please have a look at it. I do not think any of the
>>> functionality wrapped inside CONFIG_MEMCG_KMEM without CONFIG_INET is
>>> reusable for generic CONFIG_MEMCG_KMEM, right?
>> Almost right.
>>
>>
>>
>>>  }
>>> =20
>>>  /* Writing them here to avoid exposing memcg's inner layout */
>>> -#ifdef CONFIG_MEMCG_KMEM
>>> -#include <net/sock.h>
>>> -#include <net/ip.h>
>>> +#if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
>>> =20
>>>  static bool mem_cgroup_is_root(struct mem_cgroup *memcg);
>>
>> This one is. ^^^^
>=20
> But this is just a forward declaration. And btw. it makes my compiler
> complain about:
> mm/memcontrol.c:421: warning: =E2=80=98mem_cgroup_is_root=E2=80=99 declar=
ed inline after being called
> mm/memcontrol.c:421: warning: previous declaration of =E2=80=98mem_cgroup=
_is_root=E2=80=99 was here
>=20
> But I didn't care much yet. It is probaly that my compiler is too old to
> be clever about this.
>=20
Weird, this code is in tree for a long time.
So, *right now* this code is used only for inet code, so I won't oppose
your patch on this basis. I'll reuse it for kmem, but I am happy to just
rebase it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

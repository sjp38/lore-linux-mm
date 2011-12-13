Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id D06076B0284
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 15:11:44 -0500 (EST)
Message-ID: <4EE7B154.4050208@parallels.com>
Date: Wed, 14 Dec 2011 00:11:00 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v9 0/9] Request for inclusion: per-cgroup tcp memory pressure
 controls
References: <1323676029-5890-1-git-send-email-glommer@parallels.com>  <20111212.190734.1967808916779299221.davem@davemloft.net>  <4EE757D7.6060006@uclouvain.be> <1323784748.2950.4.camel@edumazet-laptop>
In-Reply-To: <1323784748.2950.4.camel@edumazet-laptop>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: christoph.paasch@uclouvain.be, David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, cgroups@vger.kernel.org

On 12/13/2011 05:59 PM, Eric Dumazet wrote:
> Le mardi 13 d=C3=A9cembre 2011 =C3=A0 14:49 +0100, Christoph Paasch a =C3=
=A9crit :
>
>> now there are plenty of compiler-warnings when CONFIG_CGROUPS is not set=
:
>>
>> In file included from include/linux/tcp.h:211:0,
>>                   from include/linux/ipv6.h:221,
>>                   from include/net/ip_vs.h:23,
>>                   from kernel/sysctl_binary.c:6:
>> include/net/sock.h:67:57: warning: =E2=80=98struct cgroup_subsys=E2=80=
=99 declared
>> inside parameter list [enabled by default]
>> include/net/sock.h:67:57: warning: its scope is only this definition or
>> declaration, which is probably not what you want [enabled by default]
>> include/net/sock.h:67:57: warning: =E2=80=98struct cgroup=E2=80=99 decla=
red inside
>> parameter list [enabled by default]
>> include/net/sock.h:68:61: warning: =E2=80=98struct cgroup_subsys=E2=80=
=99 declared
>> inside parameter list [enabled by default]
>> include/net/sock.h:68:61: warning: =E2=80=98struct cgroup=E2=80=99 decla=
red inside
>> parameter list [enabled by default]
>>
>>
>> Because struct cgroup is only declared if CONFIG_CGROUPS is enabled.
>> (cfr. linux/cgroup.h)
>>
>
> Yes, we probably need forward reference like this :
>
> Thanks !
>
> [PATCH net-next] net: fix build error if CONFIG_CGROUPS=3Dn
>
> Reported-by: Christoph Paasch<christoph.paasch@uclouvain.be>
> Signed-off-by: Eric Dumazet<eric.dumazet@gmail.com>
I am deeply sorry about that.
I was pretty sure I tested this case. But now that I looked into it, it=20
occurs to me that I may have tested it only with the Memory Cgroup=20
disabled, not with the master flag off.

Thanks for spotting this

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

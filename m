Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8E6E76B0258
	for <linux-mm@kvack.org>; Thu,  6 Oct 2011 04:39:37 -0400 (EDT)
Message-ID: <4E8D6923.7080404@parallels.com>
Date: Thu, 6 Oct 2011 12:38:59 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 6/8] tcp buffer limitation: per-cgroup limit
References: <1317730680-24352-1-git-send-email-glommer@parallels.com>  <1317730680-24352-7-git-send-email-glommer@parallels.com>  <1317732535.2440.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <4E8C1064.3030902@parallels.com> <1317805090.2473.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
In-Reply-To: <1317805090.2473.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org

On 10/05/2011 12:58 PM, Eric Dumazet wrote:
> Le mercredi 05 octobre 2011 =C3=A0 12:08 +0400, Glauber Costa a =C3=A9cri=
t :
>> On 10/04/2011 04:48 PM, Eric Dumazet wrote:
>
>>> 2) Could you add const qualifiers when possible to your pointers ?
>>
>> Well, I'll go over the patches again and see where I can add them.
>> Any specific place site you're concerned about?
>
> Everywhere its possible :
>
> It helps reader to instantly knows if a function is about to change some
> part of the object or only read it, without reading function body.
Sure it does.

So, give me your opinion on this:

most of the acessors inside struct sock do not modify the pointers,
but return an address of an element inside it (that can later on be
modified by the caller.

I think it is fine for the purpose of clarity, but to avoid warnings we=20
end up having to do stuff like this:

+#define CONSTCG(m) ((struct mem_cgroup *)(m))
+long *tcp_sysctl_mem(const struct mem_cgroup *memcg)
+{
+       return CONSTCG(memcg)->tcp.tcp_prot_mem;
+}

Is it acceptable?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

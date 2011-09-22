Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7867B9000BD
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 01:58:30 -0400 (EDT)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p8M5wRLg010044
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 22:58:27 -0700
Received: from qyk10 (qyk10.prod.google.com [10.241.83.138])
	by hpaq7.eem.corp.google.com with ESMTP id p8M5vEbK031755
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Sep 2011 22:58:26 -0700
Received: by qyk10 with SMTP id 10so4974771qyk.20
        for <linux-mm@kvack.org>; Wed, 21 Sep 2011 22:58:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1316393805-3005-2-git-send-email-glommer@parallels.com>
References: <1316393805-3005-1-git-send-email-glommer@parallels.com> <1316393805-3005-2-git-send-email-glommer@parallels.com>
From: Greg Thelen <gthelen@google.com>
Date: Wed, 21 Sep 2011 22:58:04 -0700
Message-ID: <CAHH2K0YNUNAr7SVkPYKCsU_9Cp4v=AhQ0RVBgmwNNRHJWFgUBA@mail.gmail.com>
Subject: Re: [PATCH v3 1/7] Basic kernel memory functionality for the Memory Controller
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name

On Sun, Sep 18, 2011 at 5:56 PM, Glauber Costa <glommer@parallels.com> wrot=
e:
> @@ -270,6 +274,10 @@ struct mem_cgroup {
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0struct res_counter memsw;
> =A0 =A0 =A0 =A0/*
> + =A0 =A0 =A0 =A0* the counter to account for kmem usage.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 struct res_counter kmem;
> + =A0 =A0 =A0 /*

I don't see this charged, is this used in a later patch in this series?

> @@ -5665,3 +5754,17 @@ static int __init enable_swap_account(char *s)
> =A0__setup("swapaccount=3D", enable_swap_account);
>
> =A0#endif
> +
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> +static int __init disable_kmem_account(char *s)

Minor nit.  To be consistent with the other memcg __setup options, I
think this should be renamed to enable_kmem_account().

> +{
> + =A0 =A0 =A0 /* consider enabled if no parameter or 1 is given */
> + =A0 =A0 =A0 if (!strcmp(s, "1"))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_kmem_account =3D 1;
> + =A0 =A0 =A0 else if (!strcmp(s, "0"))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_kmem_account =3D 0;
> + =A0 =A0 =A0 return 1;
> +}
> +__setup("kmemaccount=3D", disable_kmem_account);
> +
> +#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3E6186B016A
	for <linux-mm@kvack.org>; Wed,  7 Sep 2011 01:24:28 -0400 (EDT)
Received: by gyf1 with SMTP id 1so3743749gyf.14
        for <linux-mm@kvack.org>; Tue, 06 Sep 2011 22:24:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1315369399-3073-3-git-send-email-glommer@parallels.com>
References: <1315369399-3073-1-git-send-email-glommer@parallels.com> <1315369399-3073-3-git-send-email-glommer@parallels.com>
From: Paul Menage <paul@paulmenage.org>
Date: Tue, 6 Sep 2011 22:24:07 -0700
Message-ID: <CALdu-PCosvJ-SfVROLLM29RoMfxxRyW9E-_Za9A7LTAZwmkPeg@mail.gmail.com>
Subject: Re: [PATCH v2 2/9] Kernel Memory cgroup
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, netdev@vger.kernel.org, xemul@parallels.com, "David S. Miller" <davem@davemloft.net>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, "Eric W. Biederman" <ebiederm@xmission.com>

On Tue, Sep 6, 2011 at 9:23 PM, Glauber Costa <glommer@parallels.com> wrote=
:
> +
> +struct kmem_cgroup {
> + =A0 =A0 =A0 struct cgroup_subsys_state css;
> + =A0 =A0 =A0 struct kmem_cgroup *parent;
> +};

There's a parent pointer in css.cgroup, so you shouldn't need a
separate one here.

Most cgroup subsystems define this structure (and the below accessor
functions) in their .c file rather than exposing it to the world? Does
this subsystem particularly need it exposed?

> +
> +static struct cgroup_subsys_state *kmem_create(
> + =A0 =A0 =A0 struct cgroup_subsys *ss, struct cgroup *cgrp)
> +{
> + =A0 =A0 =A0 struct kmem_cgroup *sk =3D kzalloc(sizeof(*sk), GFP_KERNEL)=
;

kcg or just cg would be a better name?

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

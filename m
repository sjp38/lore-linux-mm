Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 27B0E6B004D
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 18:18:13 -0500 (EST)
Received: by yhoo22 with SMTP id o22so1091364yho.14
        for <linux-mm@kvack.org>; Thu, 23 Feb 2012 15:18:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1328972596-4142-1-git-send-email-siddhesh.poyarekar@gmail.com>
References: <4F32B776.6070007@gmail.com> <1328972596-4142-1-git-send-email-siddhesh.poyarekar@gmail.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Thu, 23 Feb 2012 18:17:52 -0500
Message-ID: <CAHGf_=oi8_s0Bxn4qSD7S_FBSgp29BPXor4hCf5-kekGnf3qEw@mail.gmail.com>
Subject: Re: [PATCH] Mark thread stack correctly in proc/<pid>/maps
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Jamie Lokier <jamie@shareable.org>, vapier@gentoo.org

Hi

This version makes sense to me. and I verified this change don't break
procps tools.

But,

> +int vm_is_stack(struct task_struct *task,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct vm_area_=
struct *vma, int in_group)
> +{
> + =A0 =A0 =A0 if (vm_is_stack_for_task(task, vma))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
> +
> + =A0 =A0 =A0 if (in_group) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct task_struct *t =3D task;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 while_each_thread(task, t) {

How protect this loop from task exiting? AFAIK, while_each_thread
require rcu_read_lock or task_list_lock.


> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (vm_is_stack_for_task(t,=
 vma))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 86DB96B0087
	for <linux-mm@kvack.org>; Mon, 16 Jan 2012 08:08:34 -0500 (EST)
Received: by yhoo21 with SMTP id o21so1357542yho.14
        for <linux-mm@kvack.org>; Mon, 16 Jan 2012 05:08:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120116112802.GB7180@jl-vm1.vm.bytemark.co.uk>
References: <1326544511-6547-1-git-send-email-siddhesh.poyarekar@gmail.com>
	<20120116112802.GB7180@jl-vm1.vm.bytemark.co.uk>
Date: Mon, 16 Jan 2012 18:38:33 +0530
Message-ID: <CAAHN_R1u_btMuF+WhHu0G895EJ=mbOPNRp7NcXEgTKv3Vs-B1A@mail.gmail.com>
Subject: Re: [PATCH] Mark thread stack correctly in proc/<pid>/maps
From: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jamie Lokier <jamie@shareable.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-man@vger.kernel.org

On Mon, Jan 16, 2012 at 4:58 PM, Jamie Lokier <jamie@shareable.org> wrote:
> Is there a reason the names aren't consistent - i.e. not vma_is_stack_gua=
rd()?

Ah, that was an error on my part; I did not notice the naming convention.

> How about simply calling it vma_is_guard(), return 1 if it's PROT_NONE
> without checking vma_is_stack() or ->vm_next/prev, and annotate the
> maps output like this:
>
> =A0 is_stack =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D> "[stack]"
> =A0 is_guard & is_stack =A0 =3D> "[stack guard]"
> =A0 is_guard & !is_stack =A0=3D> "[guard]"
>
> What do you think?

Thanks for the review. We're already marking permissions in the maps
output to convey protection, so isn't marking those vmas as [guard]
redundant?

Following that, we could just mark the thread stack guard as [stack]
without any permissions. The process stack guard page probably
deserves the [stack guard] label since it is marked differently from
the thread stack guard and will otherwise have the permissions that
the process stack has. Will that be good?

--=20
Siddhesh Poyarekar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

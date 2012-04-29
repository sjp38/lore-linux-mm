Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id EF32F6B0044
	for <linux-mm@kvack.org>; Sun, 29 Apr 2012 08:26:44 -0400 (EDT)
Received: by iajr24 with SMTP id r24so4495227iaj.14
        for <linux-mm@kvack.org>; Sun, 29 Apr 2012 05:26:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1335681937-3715-1-git-send-email-levinsasha928@gmail.com>
References: <1335681937-3715-1-git-send-email-levinsasha928@gmail.com>
From: Sasha Levin <levinsasha928@gmail.com>
Date: Sun, 29 Apr 2012 14:26:24 +0200
Message-ID: <CA+1xoqeFZHrqov=Tw=spnPbBSiPR6k1xGHFUXPmjfeL70BO4AA@mail.gmail.com>
Subject: Re: [PATCH 01/14] sysctl: provide callback for write into ctl_table entry
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@zeniv.linux.org.uk, rostedt@goodmis.org, fweisbec@gmail.com, mingo@redhat.com, a.p.zijlstra@chello.nl, paulus@samba.org, acme@ghostprotocols.net, james.l.morris@oracle.com, ebiederm@xmission.com, akpm@linux-foundation.org, tglx@linutronix.de
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-security-module@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

On Sun, Apr 29, 2012 at 8:45 AM, Sasha Levin <levinsasha928@gmail.com> wrot=
e:
> +
> + =A0 =A0 =A0 if (!error && write && table->callback)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 error =3D table->callback();
> +

Tetsuo Handa has pointed out that 'error' is actually the amount of
bytes read/written in the success case. I'll fix that for V2.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

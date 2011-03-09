Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E35798D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 08:09:16 -0500 (EST)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id p29D9DE2008194
	for <linux-mm@kvack.org>; Wed, 9 Mar 2011 05:09:13 -0800
Received: from qwd6 (qwd6.prod.google.com [10.241.193.198])
	by hpaq12.eem.corp.google.com with ESMTP id p29D8vFF003836
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 9 Mar 2011 05:09:12 -0800
Received: by qwd6 with SMTP id 6so731858qwd.1
        for <linux-mm@kvack.org>; Wed, 09 Mar 2011 05:09:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1299630721-4337-1-git-send-email-wilsons@start.ca>
References: <1299630721-4337-1-git-send-email-wilsons@start.ca>
Date: Wed, 9 Mar 2011 05:09:09 -0800
Message-ID: <AANLkTikTEi8uKeCfPLoenNx9g6fLyAqNqfVdR=4KzNB3@mail.gmail.com>
Subject: Re: [PATCH 0/5] make *_gate_vma accept mm_struct instead of task_struct
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Wilson <wilsons@start.ca>
Cc: x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, Paul Mundt <lethal@linux-sh.org>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 8, 2011 at 4:31 PM, Stephen Wilson <wilsons@start.ca> wrote:
> Morally, the question of whether an address lies in a gate vma should be =
asked
> with respect to an mm, not a particular task.
>
> Practically, dropping the dependency on task_struct will help make curren=
t and
> future operations on mm's more flexible and convenient. =A0In particular,=
 it
> allows some code paths to avoid the need to hold task_lock.

Reviewed-by: Michel Lespinasse <walken@google.com>

May I suggest ia32_compat instead of just compat for the flag name ?

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

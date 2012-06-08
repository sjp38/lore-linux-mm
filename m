Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 4B80B6B006E
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 21:20:19 -0400 (EDT)
Received: by bkcjm19 with SMTP id jm19so1666113bkc.14
        for <linux-mm@kvack.org>; Thu, 07 Jun 2012 18:20:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1206071759050.1291@eggly.anvils>
References: <20120607212114.E4F5AA02F8@akpm.mtv.corp.google.com>
 <CA+55aFxOWR_h1vqRLAd_h5_woXjFBLyBHP--P8F7WsYrciXdmA@mail.gmail.com>
 <CA+55aFyQUBXhjVLJH6Fhz9xnpfXZ=9Mej5ujt6ss7VUqT1g9Jg@mail.gmail.com> <alpine.LSU.2.00.1206071759050.1291@eggly.anvils>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 7 Jun 2012 18:19:57 -0700
Message-ID: <CA+55aFw7y5FBJm6pxiHHsoiPaVQG3A+4u6J9=4DGd8kVPjmzGQ@mail.gmail.com>
Subject: Re: [patch 12/12] mm: correctly synchronize rss-counters at exit/exec
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: akpm@linux-foundation.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, khlebnikov@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, markus@trippelsdorf.de, oleg@redhat.com, stable@vger.kernel.org

No, this is apparently that same "almost there" patch from Oleg. I
guarantee that it's wrong.

                Linus

---

[ This part, to be exact: ]

On Thu, Jun 7, 2012 at 6:16 PM, Hugh Dickins <hughd@google.com> wrote:
> --- a/kernel/tsacct.c
> +++ b/kernel/tsacct.c
> @@ -91,6 +91,7 @@ void xacct_add_tsk(struct taskstats *stats, struct task=
_struct *p)
> =A0 =A0 =A0 =A0stats->virtmem =3D p->acct_vm_mem1 * PAGE_SIZE / MB;
> =A0 =A0 =A0 =A0mm =3D get_task_mm(p);
> =A0 =A0 =A0 =A0if (mm) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sync_mm_rss(mm);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* adjust to KB unit */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stats->hiwater_rss =A0 =3D get_mm_hiwater_=
rss(mm) * PAGE_SIZE / KB;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stats->hiwater_vm =A0 =A0=3D get_mm_hiwate=
r_vm(mm) =A0* PAGE_SIZE / KB;
> --
> 1.5.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id E2D8B6B004A
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 21:49:10 -0500 (EST)
Received: by dadv6 with SMTP id v6so1895246dad.14
        for <linux-mm@kvack.org>; Wed, 15 Feb 2012 18:49:10 -0800 (PST)
Date: Wed, 15 Feb 2012 18:48:42 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: exit_mmap() BUG_ON triggering since 3.1
In-Reply-To: <CAL1RGDVQDr-h5Makto-FXHeHUkK4sJooszciiNvVR66WonQ=6w@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1202151841400.19722@eggly.anvils>
References: <20120215183317.GA26977@redhat.com> <alpine.LSU.2.00.1202151801020.19691@eggly.anvils> <CAL1RGDVQDr-h5Makto-FXHeHUkK4sJooszciiNvVR66WonQ=6w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-1684060180-1329360529=:19722"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roland Dreier <roland@purestorage.com>
Cc: Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fedoraproject.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-1684060180-1329360529=:19722
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Wed, 15 Feb 2012, Roland Dreier wrote:
> On Wed, Feb 15, 2012 at 6:14 PM, Hugh Dickins <hughd@google.com> wrote:
> > My suspicion was that it would be related to Transparent HugePages:
> > they do complicate the pagetable story. =A0And I think I have found a
> > potential culprit. =A0I don't know if nr_ptes is the only loser from
> > these two split_huge_pages calls, but assuming it is...
>=20
> Do you have an idea when this bug might have been introduced?
> Presumably it's been there since THP came in?

That's right, since THP came in (2.6.38 on mainline,
but IIRC Red Hat had THP applied to an earlier kernel).

>=20
> The reason I ask is that I have one of these exit_mm BUG_ONs
> in my pile of one-off unreproducible crashes, but in my case it
> happened with 2.6.39 (with THP enabled).  So I'm wondering if
> I can cross it off my list and blame this bug, or if it remains one
> of those inexplicable mysteries...

If you think that system could have been using swap, yes, cross it
off (unless someone points out that I'm totally wrong, because....).

But if you know that system used no swap (and didn't get involved
in any memory-failure hwpoison business), then keep on worrying!

Hugh
--8323584-1684060180-1329360529=:19722--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

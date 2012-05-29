Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id F36FA6B005C
	for <linux-mm@kvack.org>; Tue, 29 May 2012 02:43:29 -0400 (EDT)
Message-Id: <4FC48C2D02000078000867E0@nat28.tlf.novell.com>
Date: Tue, 29 May 2012 07:43:25 +0100
From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [GIT] (frontswap.v16-tag)
References: <20120518204211.GA18571@localhost.localdomain>
 <20120524202221.GA19856@phenom.dumpdata.com>
 <CA+55aFzvAMezd=ph6b0iQ=aqsJm1tOdS6HRRQ6rD8mLCJr_MhQ@mail.gmail.com>
In-Reply-To: <CA+55aFzvAMezd=ph6b0iQ=aqsJm1tOdS6HRRQ6rD8mLCJr_MhQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: hannes@cmpxchg.org, hughd@google.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, sjenning@linux.vnet.ibm.com, chris.mason@oracle.com, dan.magenheimer@oracle.com, Rik van Riel <riel@redhat.com>, ngupta@vflare.org, matthew@wil.cx

>>> On 28.05.12 at 00:29, Linus Torvalds <torvalds@linux-foundation.org> =
wrote:
> No, the real reason is that for new features like this - features that
> I don't really see myself using personally and that I'm not all that
> personally excited about - I *really* want others to pipe up with
> "yes, we're using this, and yes, we want this to be merged".
>=20
> It doesn't seem to be huge, which is great, but the deathly silence of
> nobody speaking up and saying "yes please", makes me go "ok, I won't
> pull if nobody speaks up for the feature".

Hmm, I had thought that Dan already went through this exercise,
but in case I'm mis-remembering, I'd just like to make clear that
for the last couple of years we've been making this (or its
predecessor versions) available to our SLE and openSUSE users.
I can't, however, provide numbers of actual employments of it in
the field (such simply don't exist).

Jan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 73D6B6B0082
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 21:22:48 -0500 (EST)
Received: by dakl33 with SMTP id l33so1589996dak.31
        for <linux-mm@kvack.org>; Wed, 15 Feb 2012 18:22:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1202151801020.19691@eggly.anvils>
References: <20120215183317.GA26977@redhat.com> <alpine.LSU.2.00.1202151801020.19691@eggly.anvils>
From: Roland Dreier <roland@purestorage.com>
Date: Wed, 15 Feb 2012 18:22:27 -0800
Message-ID: <CAL1RGDVQDr-h5Makto-FXHeHUkK4sJooszciiNvVR66WonQ=6w@mail.gmail.com>
Subject: Re: exit_mmap() BUG_ON triggering since 3.1
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fedoraproject.org

On Wed, Feb 15, 2012 at 6:14 PM, Hugh Dickins <hughd@google.com> wrote:
> My suspicion was that it would be related to Transparent HugePages:
> they do complicate the pagetable story. =A0And I think I have found a
> potential culprit. =A0I don't know if nr_ptes is the only loser from
> these two split_huge_pages calls, but assuming it is...

Do you have an idea when this bug might have been introduced?
Presumably it's been there since THP came in?

The reason I ask is that I have one of these exit_mm BUG_ONs
in my pile of one-off unreproducible crashes, but in my case it
happened with 2.6.39 (with THP enabled).  So I'm wondering if
I can cross it off my list and blame this bug, or if it remains one
of those inexplicable mysteries...

Thanks,
  Roland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

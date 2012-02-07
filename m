Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id ED0276B002C
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 14:36:28 -0500 (EST)
Received: by pbcwz17 with SMTP id wz17so354387pbc.14
        for <linux-mm@kvack.org>; Tue, 07 Feb 2012 11:36:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120207075500.29797.95376.stgit@zurg>
References: <20120207074905.29797.60353.stgit@zurg> <20120207075500.29797.95376.stgit@zurg>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 7 Feb 2012 11:36:08 -0800
Message-ID: <CA+55aFx-NSOmTC73q=zOmQ-i-h2KhzKnGCsyed6Pq2UGWLxiAA@mail.gmail.com>
Subject: Re: [PATCH 1/4] bitops: implement "optimized" __find_next_bit()
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org

On Mon, Feb 6, 2012 at 11:55 PM, Konstantin Khlebnikov
<khlebnikov@openvz.org> wrote:
> This patch adds =A0__find_next_bit() -- static-inline variant of find_nex=
t_bit()
> optimized for small constant size arrays, because find_next_bit() is too =
heavy
> for searching in an array with one/two long elements.
> And unlike to find_next_bit() it does not mask tail bits.

Does anybody else really want this?  My gut feel is that this
shouldn't be inline at all (the same is largely true of the existing
ones), and that nobody else really wants this. Nor do we want to
introduce yet another helper function that has very subtly different
semantics that will just confuse people.

So I suspect this should be instead a function that is internal to the
iterator code.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

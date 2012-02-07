Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 1543A6B002C
	for <linux-mm@kvack.org>; Tue,  7 Feb 2012 14:38:30 -0500 (EST)
Received: by pbcwz17 with SMTP id wz17so356211pbc.14
        for <linux-mm@kvack.org>; Tue, 07 Feb 2012 11:38:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120207074905.29797.60353.stgit@zurg>
References: <20120207074905.29797.60353.stgit@zurg>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 7 Feb 2012 11:38:09 -0800
Message-ID: <CA+55aFy3NZ2sWX0CNVd9FnPSx0mUKSe0XzDWpDsNfU21p6ebHQ@mail.gmail.com>
Subject: Re: [PATCH 0/4] radix-tree: iterating general cleanup
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org

On Mon, Feb 6, 2012 at 11:54 PM, Konstantin Khlebnikov
<khlebnikov@openvz.org> wrote:
> This patchset implements common radix-tree iteration routine and
> reworks page-cache lookup functions with using it.

So what's the advantage? Both the line counts and the bloat-o-meter
seems to imply this is all just bad.

I assume there is some upside to it, but you really don't make that
obvious, so why should anybody ever waste even a second of time
looking at this?

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

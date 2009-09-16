Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 660596B004F
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 23:56:34 -0400 (EDT)
Received: by ywh9 with SMTP id 9so6590008ywh.32
        for <linux-mm@kvack.org>; Tue, 15 Sep 2009 20:56:42 -0700 (PDT)
MIME-Version: 1.0
From: Mike Frysinger <vapier.adi@gmail.com>
Date: Tue, 15 Sep 2009 23:56:21 -0400
Message-ID: <8bd0f97a0909152056h61bfc487g6b8631966c6d72be@mail.gmail.com>
Subject: Re: 2.6.32 -mm Blackfin patches
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 15, 2009 at 19:15, Andrew Morton wrote:
> blackfin-convert-to-use-arch_gettimeoffset.patch

i thought John was merging this via some sort of patch series, but i
can pick it up in the Blackfin tree to make sure things are really
sane

> blackfin-fix-read-buffer-overflow.patch

the latter patch i merged into my tree (and i thought that i followed
up in the original posting about this)

> checkpatch-possible-types-else-cannot-start-a-type.patch
> checkpatch-handle-c99-comments-correctly-performance-issue.patch
> checkpatch-indent-checks-stop-when-we-run-out-of-continuation-lines.patch
> checkpatch-make-f-alias-file-add-help-more-verbose-help-message.patch
> checkpatch-format-strings-should-not-have-brackets-in-macros.patch
> checkpatch-limit-sn-un-matches-to-actual-bit-sizes.patch
> checkpatch-version-029.patch
> checkpatch-add-some-common-blackfin-checks.patch
>
> =C2=A0Grumpy. =C2=A0These spit perl warnings but maintainer won't talk to=
 me.

the last one shouldnt cause any warnings at all ;)
-mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

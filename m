Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 330CE6B0088
	for <linux-mm@kvack.org>; Fri, 24 Dec 2010 07:15:29 -0500 (EST)
Received: by qyk7 with SMTP id 7so7883281qyk.14
        for <linux-mm@kvack.org>; Fri, 24 Dec 2010 04:15:27 -0800 (PST)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <201012240132.oBO1W8Ub022207@imap1.linux-foundation.org>
References: <201012240132.oBO1W8Ub022207@imap1.linux-foundation.org>
Date: Fri, 24 Dec 2010 13:15:26 +0100
Message-ID: <AANLkTinegsqmSzXqqrF930abQfOBu6_MH1EToupKV214@mail.gmail.com>
Subject: Re: mmotm 2010-12-23-16-58 uploaded
From: Sedat Dilek <sedat.dilek@googlemail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Dec 24, 2010 at 1:58 AM,  <akpm@linux-foundation.org> wrote:
> The mm-of-the-moment snapshot 2010-12-23-16-58 has been uploaded to
>
> =C2=A0 http://userweb.kernel.org/~akpm/mmotm/
>
> and will soon be available at
>
> =C2=A0 git://zen-kernel.org/kernel/mmotm.git
>

The readme in [1] lists a wrong browseable GIT-repo URL:

"Alternatively, these patches are available in a git repository at

git:	git://zen-kernel.org/kernel/mmotm.git
gitweb:	http://git.zen-kernel.org/?p=3Dkernel/mmotm.git;a=3Dsummary"

Correct would be [2]:

gitweb: http://git.zen-kernel.org/mmotm/

> It contains the following patches against 2.6.37-rc7:
>
[...]
> linux-next-git-rejects.patch

Hm, the content of this patch looks a bit strange.
Is that a post-cleanup patch to linux-next merge?

- Sedat -

[1] http://userweb.kernel.org/~akpm/mmotm/mmotm-readme.txt
[2] http://git.zen-kernel.org/mmotm/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 3A7796B00D6
	for <linux-mm@kvack.org>; Mon, 14 Apr 2014 06:15:27 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id cc10so3747306wib.16
        for <linux-mm@kvack.org>; Mon, 14 Apr 2014 03:15:25 -0700 (PDT)
Received: from mail-we0-x236.google.com (mail-we0-x236.google.com [2a00:1450:400c:c03::236])
        by mx.google.com with ESMTPS id ju8si5028909wjc.189.2014.04.14.03.15.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 14 Apr 2014 03:15:24 -0700 (PDT)
Received: by mail-we0-f182.google.com with SMTP id p61so7979732wes.13
        for <linux-mm@kvack.org>; Mon, 14 Apr 2014 03:15:22 -0700 (PDT)
MIME-Version: 1.0
From: Michael Kerrisk <mtk.manpages@gmail.com>
Date: Mon, 14 Apr 2014 12:15:01 +0200
Message-ID: <CAHO5Pa0VCzR7oqNXkwELuAsNQnnvF8Xoo=CuCaM64-GzjDuoFA@mail.gmail.com>
Subject: Documenting prctl() PR_SET_THP_DISABLE and PR_GET_THP_DISABLE
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linux-man@vger.kernel.org, Michael Kerrisk-manpages <mtk.manpages@gmail.com>

Alex,

Your commit a0715cc22601e8830ace98366c0c2bd8da52af52 added the prctl()
PR_SET_THP_DISABLE and PR_GET_THP_DISABLE flags.

The text below attempts to document these flags for the prctl(3).
Could you (and anyone else who is willing) please review the text
below (one or two p[ieces of which are drawn from your commit message)
to verify that it accurately reflects reality and your intent, and
that I have not missed any significant details.

    DESCRIPTION
    ...
       PR_SET_THP_DISABLE (since Linux 3.15)
              Set the state of the "THP disable" flag for the  calling
              thread.   If  arg2 has a nonzero value, the flag is set,
              otherwise it is cleared.  Setting this flag  provides  a
              method  for disabling  transparent  huge  pages for jobs
              where the code cannot be modified, and  using  a  malloc
              hook  with madvise(2) is not an option (i.e., statically
              allocated data).  The setting of the "THP disable"  flag
              is  inherited by a child created via fork(2) and is pre=E2=80=
=90
              served across execve(2).

       PR_GET_THP_DISABLE (since Linux 3.15)
              Return (via the function result) the current setting  of
              the "THP disable" flag for the calling thread: either 1,
              if the flag is set, or 0, if it is not.
    ...
    RETURN VALUE
       On       success,       PR_GET_DUMPABLE,       PR_GET_KEEPCAPS,
       PR_GET_NO_NEW_PRIVS,    PR_GET_THP_DISABLE,    PR_CAPBSET_READ,
       PR_GET_TIMING,       PR_GET_TIMERSLACK,      PR_GET_SECUREBITS,
       PR_MCE_KILL_GET, and (if it returns) PR_GET_SECCOMP return  the
       nonnegative  values  described  above.  All other option values
       return 0 on success.  On error, -1 is returned,  and  errno  is
       set appropriately.
    ...
    ERRORS
       EINVAL option is PR_SET_THP_DISABLE and arg3, arg4, or arg5  is
              nonzero.

       EINVAL option  is  PR_GET_THP_DISABLE  and arg2, arg3, arg4, or
              arg5 is nonzero.

Thanks,

Michael



--=20
Michael Kerrisk Linux man-pages maintainer;
http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface", http://blog.man7.org/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

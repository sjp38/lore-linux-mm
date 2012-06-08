Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 313A06B006E
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 21:09:44 -0400 (EDT)
Received: by bkcjm19 with SMTP id jm19so1657784bkc.14
        for <linux-mm@kvack.org>; Thu, 07 Jun 2012 18:09:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120607180515.4afffc89.akpm@linux-foundation.org>
References: <20120608002451.GA821@redhat.com> <CA+55aFzivM8Z1Bjk3Qo2vtnQhCQ7fQ4rf_a+EXY7noXQcxL_CA@mail.gmail.com>
 <20120607180515.4afffc89.akpm@linux-foundation.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 7 Jun 2012 18:09:20 -0700
Message-ID: <CA+55aFz12eeNHGt5GV_w=brPVed3Ga9HjYy73dbusEyPpX39OQ@mail.gmail.com>
Subject: Re: a whole bunch of crashes since todays -mm merge.
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Konstantin Khlebnikov <khlebnikov@openvz.org>, Oleg Nesterov <oleg@redhat.com>

On Thu, Jun 7, 2012 at 6:05 PM, Andrew Morton <akpm@linux-foundation.org> w=
rote:
>
> It appears this is due to me fat-fingering conflict resolution last
> week. =A0That hunk is supposed to be in mm_release(), not mmput().

Ahh. That would indeed make more sense. The mmput() placement is
insane for so many reasons.

I reverted it and pushed it out, because it clearly was horrible. Even
if it is possible that Dave's problems are due to something else (but
if they started with the mm merge, I don't see anything else nearly as
scary in there)

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

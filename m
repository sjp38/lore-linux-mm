Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 3BB6F6B006E
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 22:22:46 -0400 (EDT)
Date: Thu, 7 Jun 2012 22:22:41 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: a whole bunch of crashes since todays -mm merge.
Message-ID: <20120608022240.GC7191@redhat.com>
References: <20120608002451.GA821@redhat.com>
 <CA+55aFzivM8Z1Bjk3Qo2vtnQhCQ7fQ4rf_a+EXY7noXQcxL_CA@mail.gmail.com>
 <20120607180515.4afffc89.akpm@linux-foundation.org>
 <CA+55aFz12eeNHGt5GV_w=brPVed3Ga9HjYy73dbusEyPpX39OQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CA+55aFz12eeNHGt5GV_w=brPVed3Ga9HjYy73dbusEyPpX39OQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Konstantin Khlebnikov <khlebnikov@openvz.org>, Oleg Nesterov <oleg@redhat.com>

On Thu, Jun 07, 2012 at 06:09:20PM -0700, Linus Torvalds wrote:
 > On Thu, Jun 7, 2012 at 6:05 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
 > >
 > > It appears this is due to me fat-fingering conflict resolution last
 > > week.  That hunk is supposed to be in mm_release(), not mmput().
 > 
 > Ahh. That would indeed make more sense. The mmput() placement is
 > insane for so many reasons.
 > 
 > I reverted it and pushed it out, because it clearly was horrible. Even
 > if it is possible that Dave's problems are due to something else (but
 > if they started with the mm merge, I don't see anything else nearly as
 > scary in there)

Spooky. With that reverted, I don't see those weird oopses any more,
even with the potentially suspect 8169 tracing patch reapplied. So uh, I dunno.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

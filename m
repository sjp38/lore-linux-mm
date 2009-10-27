Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id EC91E6B0073
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 02:46:42 -0400 (EDT)
Date: Tue, 27 Oct 2009 15:46:36 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Memory overcommit
In-Reply-To: <20091027153429.b36866c4.minchan.kim@barrios-desktop>
References: <2f11576a0910262310g7aea23c0n9bfc84c900879d45@mail.gmail.com> <20091027153429.b36866c4.minchan.kim@barrios-desktop>
Message-Id: <20091027154429.E2A4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, vedran.furac@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > > %check_badness.pl | sort -n | tail
> > > --
> > > 89924 A  3938 A  A mixer_applet2
> > > 90210 A  3942 A  A tomboy
> > > 94753 A  3936 A  A clock-applet
> > > 101994 A 3919 A  A pulseaudio
> > > 113525 A 4028 A  A gnome-terminal
> > > 127340 A 1 A  A  A  init
> > > 128177 A 3871 A  A nautilus
> > > 151003 A 11515 A  bash
> > > 256944 A 11653 A  mmap
> > > 425561 A 3829 A  A gnome-session
> > > --
> > > Sigh, gnome-session has twice value of mmap(1G).
> > > Of course, gnome-session only uses 6M bytes of anon.
> > > I wonder this is because gnome-session has many children..but need to
> > > dig more. Does anyone has idea ?
> > > (CCed kosaki)
> > 
> > Following output address the issue.
> > The fact is, modern desktop application linked pretty many library. it
> > makes bloat VSS size and increase
> > OOM score.
> > 
> > Ideally, We shouldn't account evictable file-backed mappings for oom_score.
> > 
> Hmm. 
> I wonder why we consider VM size for OOM kiling. 
> How about RSS size?

Because, swap out-ed bad body (e.g. fork bomb process) still should
be killed by oom.
RSS + swap-entries is acceptable to me.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

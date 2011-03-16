Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A17F58D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 11:12:12 -0400 (EDT)
From: "Jason L Tibbitts III" <tibbs@math.uh.edu>
Subject: Re: [PATCH] tmpfs: implement security.capability xattrs
References: <20110111210710.32348.1642.stgit@paris.rdu.redhat.com>
	<AANLkTi=wyaLP6gFmNxajp+HtYu3B9_KGf2o4BnYA+rwy@mail.gmail.com>
	<AANLkTi=7GyY=O2eTupPXQijcnT_55a3RnHAruJpm_5Jo@mail.gmail.com>
Date: Wed, 16 Mar 2011 10:11:38 -0500
In-Reply-To: <AANLkTi=7GyY=O2eTupPXQijcnT_55a3RnHAruJpm_5Jo@mail.gmail.com>
	(Eric Paris's message of "Wed, 2 Mar 2011 14:29:59 -0500")
Message-ID: <ufa7hbzje1h.fsf@epithumia.math.uh.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Paris <eparis@parisplace.org>
Cc: Eric Paris <eparis@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

>>>>> "EP" == Eric Paris <eparis@parisplace.org> writes:

EP> I know there exist thoughts on this patch somewhere on the
EP> internets. Let 'em rip!  I can handle it!

Well, I've been running it for a while (currently patched into Fedora
15's 2.6.38 package) in order to be able to init Fedora chroots in tmpfs
(for doing fast mock builds).  Seems to work fine for me.  Unfortunately
I'm not able to comment on the patch itself, which I guess is what it
really needs in order to make it upstream.

 - J<

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
